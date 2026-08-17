import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PaymentModal extends StatefulWidget {
  final double amount;
  final Function(String method, String transactionId) onPaymentSuccess;

  const PaymentModal({
    Key? key,
    required this.amount,
    required this.onPaymentSuccess,
  }) : super(key: key);

  @override
  State<PaymentModal> createState() => _PaymentModalState();
}

class _PaymentModalState extends State<PaymentModal> {
  String _selectedMethod = 'UPI';
  bool _isProcessing = false;
  final TextEditingController _upiController = TextEditingController(text: 'caregiver@upi');

  void _processPayment() async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    
    final txId = 'TXN-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
    Navigator.pop(context);
    widget.onPaymentSuccess(_selectedMethod, txId);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Complete Hospital Payment',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Payable Balance', style: TextStyle(fontWeight: FontWeight.w600)),
                Text(
                  '₹${widget.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text('Select Payment Method', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          _buildMethodOption('UPI', 'Google Pay, PhonePe, Paytm', Icons.qr_code_2),
          _buildMethodOption('Debit Card', 'Visa, Mastercard, RuPay', Icons.credit_card),
          _buildMethodOption('Credit Card', 'Visa, Mastercard, Amex', Icons.credit_score),
          _buildMethodOption('Net Banking', 'All Major Indian Banks', Icons.account_balance),
          const SizedBox(height: 16),
          if (_selectedMethod == 'UPI') ...[
            TextField(
              controller: _upiController,
              decoration: const InputDecoration(
                labelText: 'Enter VPA / UPI ID',
                prefixIcon: Icon(Icons.alternate_email),
              ),
            ),
            const SizedBox(height: 16),
          ],
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isProcessing ? null : _processPayment,
              child: _isProcessing
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text('Pay ₹${widget.amount.toStringAsFixed(2)} Now'),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMethodOption(String id, String subtitle, IconData icon) {
    final isSelected = _selectedMethod == id;
    return InkWell(
      onTap: () => setState(() => _selectedMethod = id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? AppColors.primaryLight.withOpacity(0.3) : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppColors.primary : AppColors.textSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAlignment.start,
                children: [
                  Text(id, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
            Radio<String>(
              value: id,
              groupValue: _selectedMethod,
              onChanged: (val) => setState(() => _selectedMethod = val!),
            ),
          ],
        ),
      ),
    );
  }
}
