// Shared Hospital Management System (HMS) & CareBridge Data Engine
// Handles live CRUD operations across all hospital staff departments
//
// This now talks to the shared Node/Express + MySQL backend
// (carebridge_backend) instead of localStorage, so the HMS web portal
// and the CareBridge mobile app read/write the exact same database.

// Point this at wherever carebridge_backend is running. If you're
// opening this HMS portal from another device (not the same PC as the
// backend), replace 'localhost' with that PC's LAN IP address, e.g.
// 'http://192.168.1.5:8080'.
const HMS_API_BASE = 'http://localhost:8080';

// Local in-memory working copy of the shared database, kept in sync
// with MySQL via loadHmsDatabase()/saveHmsDatabase() below. Falls back
// to this seed data only until the first successful fetch completes.
let hmsDatabase = {
  patients: [
    {
      admissionId: 'HMS-2026-8842',
      patientId: 'PAT-8842-EV',
      fullName: 'Eleanor Vance',
      ageGender: '58 Years • Female (A+)',
      patientPhone: '+91 98111 22334',
      roomNumber: 'ICU Room 304',
      attendingDoctor: 'Dr. Aris Thorne (Cardiology)',
      status: 'ADMITTED',
      caregiverName: 'Sarah Vance',
      caregiverId: 'CG-991823',
      caregiverPhone: '+91 98765 43210',
      relation: 'Daughter'
    }
  ],
  treatments: [
    {
      id: 1,
      admissionId: 'HMS-2026-8842',
      doctorName: 'Dr. Aris Thorne',
      dept: 'Cardiology Dept',
      date: 'Today 09:30 AM',
      note: 'Patient responding exceptionally well to IV Ceftriaxone. SpO2 stable at 98%. Maintain light liquid diet and monitor blood pressure every 4 hours.',
      vitals: 'BP: 120/80 mmHg | HR: 74 bpm | SpO2: 98% | Temp: 98.6°F'
    },
    {
      id: 2,
      admissionId: 'HMS-2026-8842',
      doctorName: 'Dr. Elena Rostova',
      dept: 'Pulmonology Dept',
      date: 'Yesterday 06:00 PM',
      note: 'Nebulization completed. Patient reported reduced breathlessness. Recommended light walking in corridor.',
      vitals: 'BP: 124/82 mmHg | HR: 78 bpm | SpO2: 97% | Temp: 98.4°F'
    }
  ],
  labReports: [
    {
      id: 'LAB-9921',
      admissionId: 'HMS-2026-8842',
      title: 'Complete Blood Count (CBC)',
      category: 'Pathology',
      status: 'Normal',
      badgeClass: 'badge-success',
      notes: 'WBC and Platelets within normal limits. Hemoglobin: 13.8 g/dL.'
    },
    {
      id: 'LAB-9925',
      admissionId: 'HMS-2026-8842',
      title: 'Cardiac Enzymes (Troponin T)',
      category: 'Biochemistry',
      status: 'Elevated (Monitored)',
      badgeClass: 'badge-warning',
      notes: 'Troponin T levels elevated at admission, dropping steadily on day 2.'
    }
  ],
  prescriptions: [
    {
      id: 'RX-101',
      admissionId: 'HMS-2026-8842',
      name: 'Ceftriaxone 1g Injection (IV)',
      dosage: '1g Once Daily (09:00 AM)',
      duration: '5 Days Pack',
      counter: 'Ground Floor Counter 3',
      token: 'PH-4082',
      status: 'Ready for Collection',
      badgeClass: 'badge-warning',
      instructions: 'Administer slowly via IV line under nursing supervision.',
      isCollected: false
    },
    {
      id: 'RX-102',
      admissionId: 'HMS-2026-8842',
      name: 'Atorvastatin 20mg Tablet',
      dosage: '1 tablet at bedtime (09:00 PM)',
      duration: '30 Tablets Pack',
      counter: 'Ground Floor Counter 3',
      token: 'PH-4079',
      status: 'Collected by Caregiver',
      badgeClass: 'badge-success',
      instructions: 'Take after dinner with water.',
      isCollected: true
    }
  ],
  billing: {
    totalBill: 64500.00,
    insuranceCovered: 50000.00,
    remainingPayable: 14500.00,
    claimStatus: 'Approved',
    items: [
      { desc: 'ICU Room Charges (3 Days @ ₹12,000/day)', category: 'Room Rent', amount: 36000.00 },
      { desc: 'Doctor & Consultant Fee (Cardiology)', category: 'Consultation', amount: 12000.00 },
      { desc: 'Pharmacy & IV Medications', category: 'Pharmacy', amount: 8500.00 },
      { desc: 'Laboratory & CT Diagnostics', category: 'Diagnostics', amount: 8000.00 }
    ]
  },
  payments: [
    { txId: 'TXN-991823', date: '13 Aug 2026', method: 'UPI (Google Pay)', amount: 10000.00, status: 'Paid' }
  ]
};

// Real-Time Cross-App Sync Engine (REST calls to the shared MySQL backend)
// A connection indicator element (id="hmsDbConnStatus") is optional —
// updateHmsConnStatus() no-ops if it isn't present in the page.
function updateHmsConnStatus(connected) {
  const el = document.getElementById('hmsDbConnStatus');
  if (!el) return;
  el.textContent = connected ? 'MySQL: Connected' : 'MySQL: Offline (retrying...)';
  el.style.color = connected ? 'var(--emerald-success)' : 'var(--rose-danger, #ef4444)';
}

// Push the current in-memory hmsDatabase to the backend, which persists
// it into MySQL. Every staff action calls this right after mutating
// hmsDatabase locally, so CareBridge sees the change on its next poll.
async function saveHmsDatabase() {
  try {
    const res = await fetch(`${HMS_API_BASE}/api/hms/sync`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(hmsDatabase),
    });
    if (!res.ok) throw new Error('Sync failed: ' + res.status);
    updateHmsConnStatus(true);
  } catch (e) {
    console.error('Failed to sync HMS database to MySQL backend:', e);
    updateHmsConnStatus(false);
  }
}

// Pull the latest shared state from MySQL (via the backend). Called on
// load and on a polling timer so changes made from the CareBridge app
// (payments, prescription pickups) show up here automatically.
async function loadHmsDatabase() {
  try {
    const res = await fetch(`${HMS_API_BASE}/api/hms/data`);
    if (!res.ok) throw new Error('Fetch failed: ' + res.status);
    const parsed = await res.json();
    if (parsed && parsed.patients && parsed.treatments) {
      hmsDatabase = parsed;
    }
    updateHmsConnStatus(true);
  } catch (e) {
    console.error('Failed to load HMS database from MySQL backend:', e);
    updateHmsConnStatus(false);
  }
}

function renderAllHmsViews() {
  renderActivePatients();
  renderDoctorFeed();
  renderLabReports();
  renderPharmacyQueue();
  renderPaymentLedger();
  inspectTable('patients');
}

// Poll the backend so updates made from the CareBridge mobile app
// (e.g. a caregiver paying a bill) appear here without a manual refresh.
setInterval(async () => {
  await loadHmsDatabase();
  renderAllHmsViews();
}, 4000);

// Department Staff Accounts & RBAC Data System
// (hmsStaffAccounts + HMS_STAFF_SESSION_KEY now live in auth.js, shared
// with login.html, so there's one source of truth for credentials.)
let activeStaff = hmsStaffAccounts.admin;

function loginHmsStaff(deptKey) {
  if (hmsStaffAccounts[deptKey]) {
    activeStaff = hmsStaffAccounts[deptKey];
    applyStaffPermissions();

    if (activeStaff.allowedDepts.includes(deptKey)) {
      switchDept(deptKey);
    } else if (activeStaff.allowedDepts.length > 0) {
      switchDept(activeStaff.allowedDepts[0]);
    }
  }
}

function logoutHmsStaff() {
  hmsClearSession();
  window.location.href = 'login.html';
}

function openStaffLoginModal() {
  logoutHmsStaff();
}

function closeStaffLoginModal() {
  const modal = document.getElementById('staffLoginModal');
  if (modal) modal.style.display = 'none';
}

function restoreStaffSession() {
  const saved = hmsGetSession();
  if (saved && hmsStaffAccounts[saved]) {
    loginHmsStaff(saved);
  } else {
    window.location.href = 'login.html';
  }
}

function applyStaffPermissions() {
  const nameElem = document.getElementById('staffUserName');
  const iconElem = document.getElementById('staffUserIcon');
  if (nameElem) nameElem.innerText = `${activeStaff.name} (${activeStaff.title})`;
  if (iconElem) iconElem.className = `fa-solid ${activeStaff.icon}`;

  // Populate the read-only doctor info display in the ward rounds form
  const doctorDisplay = document.getElementById('trtDoctorDisplay');
  const deptDisplay   = document.getElementById('trtDeptDisplay');
  if (doctorDisplay) doctorDisplay.textContent = activeStaff.name;
  if (deptDisplay)   deptDisplay.textContent   = activeStaff.title;

  const allDepts = ['reception', 'doctor', 'laboratory', 'pharmacy', 'billing', 'inspector'];
  allDepts.forEach(deptId => {
    const tabElem = document.getElementById('tab-nav-' + deptId);
    const lockSpan = document.getElementById('tab-lock-' + deptId);
    const isAllowed = activeStaff.allowedDepts.includes(deptId);

    if (!isAllowed) {
      if (lockSpan) lockSpan.innerHTML = ` <i class="fa-solid fa-lock" style="font-size: 11px; opacity: 0.7; color: var(--amber-warning);" title="Locked for ${activeStaff.title}"></i>`;
      if (tabElem) tabElem.style.opacity = '0.65';
    } else {
      if (lockSpan) lockSpan.innerHTML = '';
      if (tabElem) tabElem.style.opacity = '1';
    }
  });
}

// Initialize Application
document.addEventListener('DOMContentLoaded', async () => {
  await loadHmsDatabase();
  restoreStaffSession();
  renderAllHmsViews();
});

// Department Navigation Handler
function switchDept(deptId) {
  document.querySelectorAll('.dept-tab').forEach(t => t.classList.remove('active'));
  document.querySelectorAll('.dept-view').forEach(v => v.classList.remove('active'));

  // Look up the tab by id instead of relying on the global `event` object,
  // so this works both from a click (onclick="switchDept('doctor')") and
  // when called programmatically on login (e.g. from restoreStaffSession()).
  const tab = document.getElementById('tab-nav-' + deptId);
  if (tab) tab.classList.add('active');
  const target = document.getElementById('dept-' + deptId);
  if (target) target.classList.add('active');
}

// DEPARTMENT 1: RECEPTIONIST ADMISSION HANDLER
function handleAdmitPatient() {
  if (!activeStaff.allowedDepts.includes('reception')) {
    alert(`Access Denied: Logged in as ${activeStaff.name} (${activeStaff.title}).\nOnly Receptionist staff can admit new patients. Please switch staff account.`);
    return;
  }

  const nameEl       = document.getElementById('admPatientName');
  const ageEl        = document.getElementById('admPatientAge');
  const genderEl     = document.getElementById('admPatientGender');
  const bloodGroupEl = document.getElementById('admPatientBloodGroup');
  const phoneEl      = document.getElementById('admPatientPhone');
  const roomEl       = document.getElementById('admRoom');
  const doctorEl     = document.getElementById('admDoctor');
  const caregiverNameEl  = document.getElementById('admCaregiverName');
  const caregiverPhoneEl = document.getElementById('admCaregiverPhone');

  const isValid = hmsValidateFields([
    { id: 'admPatientName',  value: nameEl.value,  rules: [ruleRequired('Patient name'), rulePattern(HMS_VALIDATION_PATTERNS.personName, 'Enter a valid name (letters only, at least 2 characters).')] },
    { id: 'admPatientAge',   value: ageEl.value,   rules: [ruleRequired('Age'), ruleNonNegativeInt('Age')] },
    { id: 'admPatientPhone', value: phoneEl.value, rules: [ruleRequired('Patient mobile number'), ruleExactDigits10('Patient mobile number')] },
    { id: 'admCaregiverName',  value: caregiverNameEl.value,  rules: [ruleRequired('Caregiver name'), rulePattern(HMS_VALIDATION_PATTERNS.personName, 'Enter a valid name (letters only, at least 2 characters).')] },
    { id: 'admCaregiverPhone', value: caregiverPhoneEl.value, rules: [ruleRequired('Caregiver mobile number'), ruleExactDigits10('Caregiver mobile number')] },
  ]);
  if (!isValid) return;

  const name          = nameEl.value.trim();
  const age           = parseInt(ageEl.value, 10);
  const gender        = genderEl.value;
  const bloodGroup    = bloodGroupEl.value;
  const phone         = '+91' + phoneEl.value.trim();
  const room          = roomEl.value;
  const doctor        = doctorEl.value;
  const caregiverName  = caregiverNameEl.value.trim();
  const caregiverPhone = '+91' + caregiverPhoneEl.value.trim();
  const admId = 'HMS-2026-' + Math.floor(1000 + Math.random() * 9000);

  const newPatient = {
    admissionId: admId,
    patientId: 'PAT-' + Math.floor(1000 + Math.random() * 9000) + '-EV',
    fullName: name,
    ageGender: `${age} Years • ${gender} (${bloodGroup})`,
    patientPhone: phone,
    roomNumber: room,
    attendingDoctor: doctor,
    status: 'ADMITTED',
    caregiverName: caregiverName,
    caregiverId: 'CG-' + Math.floor(100000 + Math.random() * 900000),
    caregiverPhone: caregiverPhone,
    relation: 'Primary Caregiver'
  };

  hmsDatabase.patients.unshift(newPatient);
  saveHmsDatabase();
  renderActivePatients();

  alert(`Patient ${name} admitted successfully!\nAdmission ID: ${admId}\nCaregiver ${caregiverName} (${caregiverPhone}) bound to account.`);
}

function renderActivePatients() {
  const tbody = document.getElementById('activePatientsTbody');
  if (!tbody) return;

  let html = '';
  hmsDatabase.patients.forEach(p => {
    html += `
      <tr>
        <td>
          <strong>${p.fullName}</strong><br>
          <span style="font-size: 11px; color: var(--text-secondary);">${p.ageGender} • ${p.patientPhone}</span>
        </td>
        <td><strong>${p.admissionId}</strong></td>
        <td>${p.caregiverName} (${p.caregiverPhone})</td>
        <td>${p.roomNumber}</td>
        <td><span class="badge badge-success">${p.status}</span></td>
      </tr>
    `;
  });
  tbody.innerHTML = html;

  const statCount = document.getElementById('statPatientsCount');
  if (statCount) statCount.innerText = hmsDatabase.patients.length;
}

// DEPARTMENT 2: DOCTOR WARD ROUNDS HANDLER
function handleAddTreatment() {
  if (!activeStaff.allowedDepts.includes('doctor')) {
    alert(`Access Denied: Logged in as ${activeStaff.name} (${activeStaff.title}).\nOnly Doctor/Physician staff can log ward round notes. Please switch staff account.`);
    return;
  }

  const noteEl   = document.getElementById('trtNote');
  const bpSysEl  = document.getElementById('trtBpSys');
  const bpDiaEl  = document.getElementById('trtBpDia');
  const spo2El   = document.getElementById('trtSpo2');
  const hrEl     = document.getElementById('trtHr');
  const tempEl   = document.getElementById('trtTemp');

  const isValid = hmsValidateFields([
    { id: 'trtNote',   value: noteEl.value,   rules: [ruleRequired('Clinical note'), ruleMinLength(10, 'Clinical note')] },
    { id: 'trtBpSys',  value: bpSysEl.value,  rules: [ruleRequired('Systolic BP'), ruleNumericFloat('Systolic BP')] },
    { id: 'trtBpDia',  value: bpDiaEl.value,  rules: [ruleRequired('Diastolic BP'), ruleNumericFloat('Diastolic BP')] },
    { id: 'trtSpo2',   value: spo2El.value,   rules: [ruleRequired('SpO2'), ruleNumericFloat('SpO2')] },
    { id: 'trtHr',     value: hrEl.value,     rules: [ruleRequired('Heart rate'), ruleNumericFloat('Heart rate')] },
    { id: 'trtTemp',   value: tempEl.value,   rules: [ruleRequired('Temperature'), ruleNumericFloat('Temperature')] },
  ]);
  if (!isValid) return;

  // Doctor name & dept come from the active session, shown as read-only display
  const doctor = activeStaff.name;
  const dept   = activeStaff.title;
  const note   = noteEl.value.trim();
  const bp     = `${parseFloat(bpSysEl.value)}/${parseFloat(bpDiaEl.value)} mmHg`;
  const spo2   = `${parseFloat(spo2El.value)}%`;
  const hr     = `${parseFloat(hrEl.value)} bpm`;
  const temp   = `${parseFloat(tempEl.value)}°F`;

  const newTrt = {
    id: hmsDatabase.treatments.length + 1,
    admissionId: 'HMS-2026-8842',
    doctorName: doctor,
    dept: dept,
    date: 'Just Now',
    note: note,
    vitals: `BP: ${bp} | HR: ${hr} | SpO2: ${spo2} | Temp: ${temp}`
  };

  hmsDatabase.treatments.unshift(newTrt);
  saveHmsDatabase();
  renderDoctorFeed();

  alert('Doctor Treatment Instruction logged & broadcasted to Caregiver app!');
}

function renderDoctorFeed() {
  const feed = document.getElementById('doctorTimelineFeed');
  if (!feed) return;

  let html = '';
  hmsDatabase.treatments.forEach(t => {
    html += `
      <div style="background: var(--surface-variant); padding: 10px; border-radius: 8px; margin-bottom: 8px;">
        <div style="display: flex; justify-content: space-between; font-size: 12px; margin-bottom: 4px;">
          <strong>${t.doctorName} (${t.dept})</strong>
          <span style="color: var(--cyan-primary); font-weight: 700;">${t.date}</span>
        </div>
        <div style="font-size: 12px; color: var(--text-secondary);">${t.note}</div>
        <div style="font-size: 11px; font-weight: 700; color: var(--navy-dark); margin-top: 4px;">Vitals: ${t.vitals}</div>
      </div>
    `;
  });
  feed.innerHTML = html;

  const statTrt = document.getElementById('statTreatmentsCount');
  if (statTrt) statTrt.innerText = hmsDatabase.treatments.length;
}

// ISSUE PRESCRIPTION HANDLER
function handleAddPrescription() {
  if (!activeStaff.allowedDepts.includes('doctor')) {
    alert(`Access Denied: Logged in as ${activeStaff.name} (${activeStaff.title}).\nOnly Physician staff can issue prescriptions. Please switch staff account.`);
    return;
  }

  const nameEl     = document.getElementById('rxMedName');
  const dosageEl   = document.getElementById('rxDosage');
  const durationEl = document.getElementById('rxDuration');

  const isValid = hmsValidateFields([
    { id: 'rxDosage',   value: dosageEl.value,   rules: [ruleRequired('Dosage'), ruleMinLength(3, 'Dosage')] },
    { id: 'rxDuration', value: durationEl.value, rules: [ruleRequired('Duration'), ruleMinLength(3, 'Duration')] },
  ]);
  if (!isValid) return;

  const name     = nameEl.value;
  const dosage   = dosageEl.value.trim();
  const duration = durationEl.value.trim();
  const rxId     = 'RX-' + Math.floor(100 + Math.random() * 900);
  const token    = 'PH-' + Math.floor(1000 + Math.random() * 9000);

  const newRx = {
    id: rxId,
    admissionId: 'HMS-2026-8842',
    name: name,
    dosage: dosage,
    duration: duration,
    counter: 'Ground Floor Counter 3',
    token: token,
    status: 'Ready for Collection',
    badgeClass: 'badge-warning',
    instructions: '',
    isCollected: false
  };

  hmsDatabase.prescriptions.unshift(newRx);
  saveHmsDatabase();
  renderPharmacyQueue();

  alert(`Prescription for ${name} issued to Pharmacy Dispensing Counter 3!\nToken: ${token}`);
}

// DEPARTMENT 3: LABORATORY HANDLER
function handleAddLabReport() {
  if (!activeStaff.allowedDepts.includes('laboratory')) {
    alert(`Access Denied: Logged in as ${activeStaff.name} (${activeStaff.title}).\nOnly Pathology & Laboratory staff can upload diagnostic reports. Please switch staff account.`);
    return;
  }

  const nameEl     = document.getElementById('labName');
  const categoryEl = document.getElementById('labCategory');
  const statusEl   = document.getElementById('labStatus');
  const notesEl    = document.getElementById('labNotes');

  const isValid = hmsValidateFields([
    { id: 'labNotes', value: notesEl.value, rules: [ruleRequired('Result notes'), ruleMinLength(10, 'Result notes')] },
  ]);
  if (!isValid) return;

  const name     = nameEl.value;
  const category = categoryEl.value;
  const status   = statusEl.value;
  const notes    = notesEl.value.trim();
  const refNo    = 'LAB-' + Math.floor(1000 + Math.random() * 9000);

  let badgeClass = 'badge-success';
  if (status.includes('Elevated') || status.includes('Pending')) badgeClass = 'badge-warning';
  if (status.includes('Critical')) badgeClass = 'badge-danger';

  const newLab = {
    id: refNo,
    admissionId: 'HMS-2026-8842',
    title: name,
    category: category,
    status: status,
    badgeClass: badgeClass,
    notes: notes
  };

  hmsDatabase.labReports.unshift(newLab);
  saveHmsDatabase();
  renderLabReports();

  alert(`Diagnostic Report ${name} uploaded successfully!\nReference: ${refNo}`);
}

function renderLabReports() {
  const tbody = document.getElementById('labReportsTbody');
  if (!tbody) return;

  let html = '';
  hmsDatabase.labReports.forEach(r => {
    html += `
      <tr>
        <td><strong>${r.title}</strong></td>
        <td>${r.category}</td>
        <td><code>${r.id}</code></td>
        <td><span class="badge ${r.badgeClass}">${r.status}</span></td>
      </tr>
    `;
  });
  tbody.innerHTML = html;
}

// DEPARTMENT 4: PHARMACY DISPENSING HANDLER
function renderPharmacyQueue() {
  const tbody = document.getElementById('pharmacyDispensingTbody');
  if (!tbody) return;

  let html = '';
  hmsDatabase.prescriptions.forEach((rx, index) => {
    html += `
      <tr>
        <td><strong>${rx.name}</strong><br><span style="font-size: 11px; color: var(--text-secondary);">${rx.instructions}</span></td>
        <td>${rx.dosage}<br><span style="font-size: 11px; color: var(--text-secondary);">${rx.duration}</span></td>
        <td><strong>${rx.counter}</strong><br>Token: <code>${rx.token}</code></td>
        <td><span class="badge ${rx.isCollected ? 'badge-success' : 'badge-warning'}">${rx.status}</span></td>
        <td>
          <button class="btn ${rx.isCollected ? 'btn-outline' : 'btn-warning'}" style="padding: 4px 10px; font-size: 11px;" onclick="toggleHmsPharmacyPickup(${index})">
            ${rx.isCollected ? 'Reset Status' : 'Mark as Collected'}
          </button>
        </td>
      </tr>
    `;
  });
  tbody.innerHTML = html;
}

function toggleHmsPharmacyPickup(index) {
  if (!activeStaff.allowedDepts.includes('pharmacy')) {
    alert(`Access Denied: Logged in as ${activeStaff.name} (${activeStaff.title}).\nOnly Pharmacy staff can update medicine collection status. Please switch staff account.`);
    return;
  }

  const rx = hmsDatabase.prescriptions[index];
  rx.isCollected = !rx.isCollected;
  if (rx.isCollected) {
    rx.status = 'Collected by Caregiver';
    rx.badgeClass = 'badge-success';
  } else {
    rx.status = 'Ready for Collection';
    rx.badgeClass = 'badge-warning';
  }
  renderPharmacyQueue();
  saveHmsDatabase();
}

// DEPARTMENT 5: BILLING HANDLER
function handleAddBillItem() {
  if (!activeStaff.allowedDepts.includes('billing')) {
    alert(`Access Denied: Logged in as ${activeStaff.name} (${activeStaff.title}).\nOnly Billing Officers can add hospital charges. Please switch staff account.`);
    return;
  }

  const descEl = document.getElementById('billDesc');
  const categoryEl = document.getElementById('billCategory');
  const amountEl = document.getElementById('billAmount');

  const isValid = hmsValidateFields([
    { id: 'billDesc', value: descEl.value, rules: [ruleRequired('Charge description'), ruleMinLength(3, 'Charge description')] },
    { id: 'billAmount', value: amountEl.value, rules: [rulePositiveNumber('Amount')] },
  ]);
  if (!isValid) return;

  const desc = descEl.value.trim();
  const category = categoryEl.value;
  const amount = parseFloat(amountEl.value);

  hmsDatabase.billing.items.push({ desc: desc, category: category, amount: amount });
  hmsDatabase.billing.totalBill += amount;
  hmsDatabase.billing.remainingPayable = hmsDatabase.billing.totalBill - hmsDatabase.billing.insuranceCovered;

  renderPaymentLedger();
  saveHmsDatabase();
  alert(`Hospital Charge of ₹${amount} added to bill!\nUpdated Remaining Payable: ₹${hmsDatabase.billing.remainingPayable}`);
}

function handleUpdateInsuranceStatus() {
  if (!activeStaff.allowedDepts.includes('billing')) {
    alert(`Access Denied: Logged in as ${activeStaff.name} (${activeStaff.title}).\nOnly Billing Officers can update insurance claim status. Please switch staff account.`);
    return;
  }

  const status = document.getElementById('insuranceClaimStatusSelect').value;
  hmsDatabase.billing.claimStatus = status;
  saveHmsDatabase();
  alert(`Cashless Insurance Claim status updated to: ${status}`);
}

function renderPaymentLedger() {
  const tbody = document.getElementById('paymentLedgerTbody');
  if (!tbody) return;

  let html = '';
  hmsDatabase.payments.forEach(p => {
    html += `
      <tr>
        <td><code>${p.txId}</code></td>
        <td>${p.date}</td>
        <td>${p.method}</td>
        <td><strong style="color: var(--emerald-success);">₹${p.amount.toFixed(2)}</strong></td>
        <td><span class="badge badge-success">${p.status}</span></td>
      </tr>
    `;
  });
  tbody.innerHTML = html;

  const statBill = document.getElementById('statBillBalance');
  if (statBill) statBill.innerText = `₹${hmsDatabase.billing.remainingPayable.toFixed(2)}`;
}

// DEPARTMENT 6: DATABASE INSPECTOR HANDLER
function inspectTable(tableName) {
  const container = document.getElementById('tableInspectorContainer');
  if (!container) return;

  let data = hmsDatabase[tableName] || hmsDatabase.patients;
  if (tableName === 'billing') data = hmsDatabase.billing.items;

  if (!Array.isArray(data) || data.length === 0) {
    container.innerHTML = '<div style="padding: 16px; color: var(--text-secondary);">No records found in table.</div>';
    return;
  }

  const keys = Object.keys(data[0]);
  let html = '<table class="hms-table"><thead><tr>';
  keys.forEach(k => html += `<th>${k}</th>`);
  html += '</tr></thead><tbody>';

  data.forEach(row => {
    html += '<tr>';
    keys.forEach(k => {
      let val = row[k];
      if (typeof val === 'object') val = JSON.stringify(val);
      html += `<td>${val}</td>`;
    });
    html += '</tr>';
  });
  html += '</tbody></table>';

  container.innerHTML = html;
}
