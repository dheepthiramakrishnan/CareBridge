// ====================================================================
// CareBridge / HMS Shared Backend
// One Express + MySQL API, called by BOTH:
//   - hms_staff_portal (web)      -> writes doctor/lab/pharmacy/billing data
//   - carebridge_app (Flutter)    -> reads it + writes payments/pickups
// Because both talk to the same MySQL database (carebridge_db) through
// this single server, any update made in the HMS instantly shows up in
// CareBridge (and vice versa) the next time that app polls/reads.
// ====================================================================

require('dotenv').config();
const express = require('express');
const cors = require('cors');
const mysql = require('mysql2/promise');

const app = express();
const PORT = process.env.PORT || 8080;

app.use(cors());
app.use(express.json({ limit: '2mb' }));

const pool = mysql.createPool({
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 3306,
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || 'root',
  database: process.env.DB_NAME || 'carebridge_db',
  waitForConnections: true,
  connectionLimit: 10,
  charset: 'utf8mb4',
});

// ---------------------------------------------------------------
// Helpers: map MySQL rows <-> the exact JSON shape the frontends use
// ---------------------------------------------------------------
function mapPatient(p) {
  return {
    admissionId: p.admission_id,
    patientId: p.patient_id,
    fullName: p.full_name,
    ageGender: p.age_gender,
    patientPhone: p.patient_phone,
    roomNumber: p.room_number,
    attendingDoctor: p.attending_doctor,
    status: p.status,
    caregiverName: p.caregiver_name,
    caregiverId: p.caregiver_id,
    caregiverPhone: p.caregiver_phone,
    relation: p.relation,
  };
}
function mapTreatment(t) {
  return {
    id: t.id,
    admissionId: t.admission_id,
    doctorName: t.doctor_name,
    dept: t.dept,
    date: t.date_label,
    note: t.note,
    vitals: t.vitals,
  };
}
function mapLabReport(l) {
  return {
    id: l.id,
    admissionId: l.admission_id,
    title: l.title,
    category: l.category,
    status: l.status,
    badgeClass: l.badge_class,
    notes: l.notes,
  };
}
function mapPrescription(r) {
  return {
    id: r.id,
    admissionId: r.admission_id,
    name: r.name,
    dosage: r.dosage,
    duration: r.duration,
    counter: r.counter,
    token: r.token,
    status: r.status,
    badgeClass: r.badge_class,
    instructions: r.instructions,
    isCollected: !!r.is_collected,
  };
}
function mapBillItem(i) {
  return { desc: i.description, category: i.category, amount: Number(i.amount) };
}
function mapPayment(p) {
  return {
    txId: p.tx_id,
    date: p.date_label,
    method: p.method,
    amount: Number(p.amount),
    status: p.status,
  };
}

// Build the full snapshot exactly as hmsDatabase / carebridgeHmsDb expect it
async function buildSnapshot() {
  const [patients] = await pool.query('SELECT * FROM patients ORDER BY created_at DESC');
  const [treatments] = await pool.query('SELECT * FROM treatments ORDER BY id DESC');
  const [labReports] = await pool.query('SELECT * FROM lab_reports ORDER BY created_at DESC');
  const [prescriptions] = await pool.query('SELECT * FROM prescriptions ORDER BY created_at DESC');
  const [billingRows] = await pool.query('SELECT * FROM billing_summary LIMIT 1');
  const [billItems] = await pool.query('SELECT * FROM bill_items');
  const [payments] = await pool.query('SELECT * FROM payments ORDER BY id DESC');

  const billingRow = billingRows[0] || {
    total_bill: 0, insurance_covered: 0, remaining_payable: 0, claim_status: 'Pending',
  };

  return {
    patients: patients.map(mapPatient),
    treatments: treatments.map(mapTreatment),
    labReports: labReports.map(mapLabReport),
    prescriptions: prescriptions.map(mapPrescription),
    billing: {
      totalBill: Number(billingRow.total_bill),
      insuranceCovered: Number(billingRow.insurance_covered),
      remainingPayable: Number(billingRow.remaining_payable),
      claimStatus: billingRow.claim_status,
      items: billItems.map(mapBillItem),
    },
    payments: payments.map(mapPayment),
  };
}

// ---------------------------------------------------------------
// 1. GET full shared snapshot — polled by both HMS portal & CareBridge
// ---------------------------------------------------------------
app.get('/api/hms/data', async (req, res) => {
  try {
    res.json(await buildSnapshot());
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

// ---------------------------------------------------------------
// 2. POST full snapshot sync — either app can push its whole local
//    working copy back; the server replaces the DB rows with it in
//    one transaction, so both sides converge on the same MySQL state.
// ---------------------------------------------------------------
app.post('/api/hms/sync', async (req, res) => {
  const db = req.body || {};
  const conn = await pool.getConnection();
  try {
    await conn.beginTransaction();

    if (Array.isArray(db.patients)) {
      await conn.query('DELETE FROM patients WHERE admission_id NOT IN (?)', [
        db.patients.length ? db.patients.map((p) => p.admissionId) : [''],
      ]);
      for (const p of db.patients) {
        await conn.query(
          `INSERT INTO patients (admission_id, patient_id, full_name, age_gender, patient_phone, room_number, attending_doctor, status, caregiver_name, caregiver_id, caregiver_phone, relation)
           VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
           ON DUPLICATE KEY UPDATE patient_id=VALUES(patient_id), full_name=VALUES(full_name), age_gender=VALUES(age_gender),
             patient_phone=VALUES(patient_phone), room_number=VALUES(room_number), attending_doctor=VALUES(attending_doctor),
             status=VALUES(status), caregiver_name=VALUES(caregiver_name), caregiver_id=VALUES(caregiver_id),
             caregiver_phone=VALUES(caregiver_phone), relation=VALUES(relation)`,
          [p.admissionId, p.patientId, p.fullName, p.ageGender, p.patientPhone, p.roomNumber, p.attendingDoctor, p.status, p.caregiverName, p.caregiverId, p.caregiverPhone, p.relation]
        );
      }
    }

    if (Array.isArray(db.treatments)) {
      await conn.query('DELETE FROM treatments');
      // Frontends keep newest-first (unshift); insert oldest-first so
      // auto-increment id order (and our ORDER BY id DESC on read) comes
      // back out newest-first again.
      for (const t of [...db.treatments].reverse()) {
        await conn.query(
          `INSERT INTO treatments (admission_id, doctor_name, dept, date_label, note, vitals) VALUES (?, ?, ?, ?, ?, ?)`,
          [t.admissionId, t.doctorName, t.dept, t.date, t.note, t.vitals]
        );
      }
    }

    if (Array.isArray(db.labReports)) {
      await conn.query('DELETE FROM lab_reports');
      for (const l of [...db.labReports].reverse()) {
        await conn.query(
          `INSERT INTO lab_reports (id, admission_id, title, category, status, badge_class, notes) VALUES (?, ?, ?, ?, ?, ?, ?)`,
          [l.id, l.admissionId, l.title, l.category, l.status, l.badgeClass, l.notes]
        );
      }
    }

    if (Array.isArray(db.prescriptions)) {
      await conn.query('DELETE FROM prescriptions');
      for (const r of [...db.prescriptions].reverse()) {
        await conn.query(
          `INSERT INTO prescriptions (id, admission_id, name, dosage, duration, counter, token, status, badge_class, instructions, is_collected) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
          [r.id, r.admissionId, r.name, r.dosage, r.duration, r.counter, r.token, r.status, r.badgeClass, r.instructions, r.isCollected ? 1 : 0]
        );
      }
    }

    if (db.billing) {
      const admissionId = (db.patients && db.patients[0] && db.patients[0].admissionId) || 'HMS-2026-8842';
      await conn.query(
        `INSERT INTO billing_summary (admission_id, total_bill, insurance_covered, remaining_payable, claim_status)
         VALUES (?, ?, ?, ?, ?)
         ON DUPLICATE KEY UPDATE total_bill=VALUES(total_bill), insurance_covered=VALUES(insurance_covered),
           remaining_payable=VALUES(remaining_payable), claim_status=VALUES(claim_status)`,
        [admissionId, db.billing.totalBill || 0, db.billing.insuranceCovered || 0, db.billing.remainingPayable || 0, db.billing.claimStatus || 'Pending']
      );

      if (Array.isArray(db.billing.items)) {
        await conn.query('DELETE FROM bill_items');
        for (const i of db.billing.items) {
          await conn.query(
            `INSERT INTO bill_items (admission_id, description, category, amount) VALUES (?, ?, ?, ?)`,
            [admissionId, i.desc, i.category, i.amount]
          );
        }
      }
    }

    if (Array.isArray(db.payments)) {
      const admissionId = (db.patients && db.patients[0] && db.patients[0].admissionId) || 'HMS-2026-8842';
      await conn.query('DELETE FROM payments');
      for (const p of [...db.payments].reverse()) {
        await conn.query(
          `INSERT INTO payments (tx_id, admission_id, date_label, method, amount, status) VALUES (?, ?, ?, ?, ?, ?)`,
          [p.txId, admissionId, p.date, p.method, p.amount, p.status]
        );
      }
    }

    await conn.commit();
    res.json({ success: true, snapshot: await buildSnapshot() });
  } catch (err) {
    await conn.rollback();
    console.error(err);
    res.status(500).json({ error: err.message });
  } finally {
    conn.release();
  }
});

// ---------------------------------------------------------------
// 3. Granular convenience endpoints (used by the Flutter app so it
//    doesn't have to reconstruct the whole snapshot for one action)
// ---------------------------------------------------------------

// Toggle a prescription's pickup status
app.put('/api/hms/prescriptions/:id/collect', async (req, res) => {
  try {
    const { id } = req.params;
    const { isCollected } = req.body;
    const status = isCollected ? 'Collected by Caregiver' : 'Ready for Collection';
    const badgeClass = isCollected ? 'badge-success' : 'badge-warning';
    await pool.query(
      'UPDATE prescriptions SET is_collected = ?, status = ?, badge_class = ? WHERE id = ?',
      [isCollected ? 1 : 0, status, badgeClass, id]
    );
    res.json({ success: true, snapshot: await buildSnapshot() });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

// Record a caregiver payment (clears remaining payable, matching existing UI logic)
app.post('/api/hms/payments', async (req, res) => {
  const conn = await pool.getConnection();
  try {
    const { admissionId, method } = req.body;
    const targetAdmission = admissionId || 'HMS-2026-8842';
    const txId = 'TXN-' + Math.floor(100000 + Math.random() * 900000);

    await conn.beginTransaction();
    const [billingRows] = await conn.query('SELECT remaining_payable FROM billing_summary WHERE admission_id = ?', [targetAdmission]);
    const paidAmt = billingRows[0] ? Number(billingRows[0].remaining_payable) : 0;

    await conn.query('UPDATE billing_summary SET remaining_payable = 0 WHERE admission_id = ?', [targetAdmission]);
    await conn.query(
      'INSERT INTO payments (tx_id, admission_id, date_label, method, amount, status) VALUES (?, ?, ?, ?, ?, ?)',
      [txId, targetAdmission, 'Today', (method || 'UPI') + ' (Caregiver App)', paidAmt, 'Paid']
    );
    await conn.commit();
    res.json({ success: true, txId, amount: paidAmt, snapshot: await buildSnapshot() });
  } catch (err) {
    await conn.rollback();
    console.error(err);
    res.status(500).json({ error: err.message });
  } finally {
    conn.release();
  }
});

app.get('/api/health', async (req, res) => {
  try {
    await pool.query('SELECT 1');
    res.json({ status: 'ok', database: 'connected' });
  } catch (err) {
    res.status(500).json({ status: 'error', database: 'disconnected', error: err.message });
  }
});

app.listen(PORT, '0.0.0.0', () => {
  console.log('====================================================');
  console.log('CareBridge / HMS Shared MySQL REST API Server');
  console.log(`Running at: http://localhost:${PORT}`);
  console.log(`Health check: http://localhost:${PORT}/api/health`);
  console.log(`Full snapshot: http://localhost:${PORT}/api/hms/data`);
  console.log('====================================================');
});
