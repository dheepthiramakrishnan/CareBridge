import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/custom_card.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/widgets/payment_modal.dart';
import '../../core/widgets/digital_receipt_sheet.dart';

class BillingScreen extends StatefulWidget {
  final CaregiverRole currentRole;

  const BillingScreen({Key? key, required this.currentRole}) : super(key: key);

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  double _totalBill = 64500.00;
  double _insuranceCovered = 50000.00;
  double _remainingAmount = 14500.00;

  final List<Map<String, String>> _paymentHistory = [
    {
      'txId': 'TXN-991823',
      'date': '13 Aug 2026',
      'amount': '₹10,000.00',
      'method': 'UPI (Google Pay)',
      'status': 'Paid (Admission Deposit)',
    },
  ];

  void _showPaymentModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return PaymentModal(
          amount: _remainingAmount,
          onPaymentSuccess: (method, txId) {
            final dateStr = 'Today, ${TimeOfDay.now().format(context)}';
            setState(() {
              _paymentHistory.insert(0, {
                'txId': txId,
                'date': dateStr,
                'amount': '₹${_remainingAmount.toStringAsFixed(2)}',
                'method': method,
                'status': 'Paid (Settled)',
              });
              _remainingAmount = 0.00;
            });
            _showReceipt(txId, method, 14500.00, dateStr);
          },
        );
      },
    );
  }

  void _showReceipt(String txId, String method, double amt, String date) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DigitalReceiptSheet(
          transactionId: txId,
          method: method,
          amount: amt,
          patientName: AppConstants.demoPatientName,
          admissionId: AppConstants.demoAdmissionId,
          date: date,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPrimary = widget.currentRole == CaregiverRole.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hospital Billing & Payments'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAlignment.start,
          children: [
            // Bill Summary Banner
            CustomCard(
              backgroundColor: AppColors.primary,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSummaryColumn('Total Bill', '₹${_totalBill.toStringAsFixed(2)}'),
                      _buildSummaryColumn('Insurance Covered', '₹${_insuranceCovered.toStringAsFixed(2)}'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAlignment.start,
                        children: [
                          const Text('Remaining Payable Balance', style: TextStyle(color: Colors.white70, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text(
                            '₹${_remainingAmount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: _remainingAmount == 0 ? AppColors.successLight : Colors.white,
                            ),
                          ),
                        ],
                      ),
                      if (isPrimary && _remainingAmount > 0)
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.primary,
                          ),
                          onPressed: _showPaymentModal,
                          child: const Text('Pay Now'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Itemized Bill Breakdown
            const Text('Itemized Hospital Charges', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            CustomCard(
              child: Column(
                children: const [
                  _BillRow('ICU Room Charges (3 Days @ ₹12,000/day)', '₹36,000.00'),
                  _BillRow('Doctor & Consultant Fee (Cardiology)', '₹12,000.00'),
                  _BillRow('Pharmacy & IV Medications', '₹8,500.00'),
                  _BillRow('Laboratory & CT Diagnostics', '₹8,000.00'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Payment History
            const Text('Payment History & Digital Receipts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _paymentHistory.length,
              itemBuilder: (context, index) {
                final tx = _paymentHistory[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: CustomCard(
                    onTap: () => _showReceipt(tx['txId']!, tx['method']!, 14500.00, tx['date']!),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAlignment.start,
                          children: [
                            Text(tx['txId']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            const SizedBox(height: 4),
                            Text('${tx['method']} • ${tx['date']}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAlignment.end,
                          children: [
                            Text(tx['amount']!, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.success, fontSize: 15)),
                            const SizedBox(height: 4),
                            const StatusBadge(label: 'Receipt Available', type: BadgeType.success),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryColumn(String label, String val) {
    return Column(
      crossAxisAlignment: CrossAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 4),
        Text(val, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
      ],
    );
  }
}

class _BillRow extends StatelessWidget {
  final String label;
  final String amount;

  const _BillRow(this.label, this.amount, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary))),
          Text(amount, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
