import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/custom_card.dart';
import '../../core/widgets/status_badge.dart';

class AuthScreen extends StatefulWidget {
  final Function(CaregiverRole role) onLoginSuccess;

  const AuthScreen({Key? key, required this.onLoginSuccess}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _phoneController = TextEditingController(text: AppConstants.demoCaregiverPhone);
  final _otpController = TextEditingController(text: '784291');
  final _admissionIdController = TextEditingController(text: AppConstants.demoAdmissionId);

  bool _otpSent = false;
  bool _isLoading = false;
  CaregiverRole _detectedRole = CaregiverRole.primary;

  void _sendOtp() async {
    if (_admissionIdController.text.trim().isEmpty || _phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter Admission ID and Mobile Number')),
      );
      return;
    }

    // Role detection based on mobile number
    final phone = _phoneController.text.trim();
    if (phone.contains('98123') || phone.contains('Family')) {
      _detectedRole = CaregiverRole.family;
    } else {
      _detectedRole = CaregiverRole.primary;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() {
      _isLoading = false;
      _otpSent = true;
    });
  }

  void _verifyAndRegister() async {
    if (_otpController.text.trim().length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid 6-digit OTP')),
      );
      return;
    }
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1000));
    setState(() => _isLoading = false);
    widget.onLoginSuccess(_detectedRole);
  }

  void _selectDemoAccount(String phone, CaregiverRole role) {
    setState(() {
      _phoneController.text = phone;
      _admissionIdController.text = AppConstants.demoAdmissionId;
      _detectedRole = role;
    });
    _sendOtp();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAlignment.start,
              children: [
                const SizedBox(height: 10),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.lock_clock,
                      size: 46,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Center(
                  child: Text(
                    AppConstants.appName,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const Center(
                  child: Text(
                    AppConstants.appTagline,
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),

                // Explanation Banner
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.infoLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.shield_outlined, color: AppColors.primary, size: 22),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Phone OTP Login is required upon opening CareBridge. Invited family members receive Read-Only access upon mobile OTP verification.',
                          style: TextStyle(fontSize: 12, color: AppColors.textPrimary, height: 1.3),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                const Text(
                  'Caregiver & Family OTP Authentication',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Enter Admission ID and your registered Mobile Number to receive Phone OTP.',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),

                // Inputs
                TextField(
                  controller: _admissionIdController,
                  enabled: !_otpSent,
                  decoration: const InputDecoration(
                    labelText: 'Admitted Patient Admission ID',
                    prefixIcon: Icon(Icons.badge_outlined),
                    hintText: 'e.g. HMS-2026-8842',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _phoneController,
                  enabled: !_otpSent,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Registered Mobile Number',
                    prefixIcon: Icon(Icons.phone_android),
                    hintText: '+91 98765 43210',
                  ),
                ),

                // Quick Demo Account Buttons
                if (!_otpSent) ...[
                  const SizedBox(height: 14),
                  const Text('Select Registered Account:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _selectDemoAccount('+91 98765 43210', CaregiverRole.primary),
                          icon: const Icon(Icons.star, size: 16),
                          label: const Text('Primary Caregiver', style: TextStyle(fontSize: 11)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _selectDemoAccount('+91 98123 76543', CaregiverRole.family),
                          icon: const Icon(Icons.family_restroom, size: 16),
                          label: const Text('Family Member', style: TextStyle(fontSize: 11)),
                        ),
                      ),
                    ],
                  ),
                ],

                // Tracked Patient Details Preview Card (Appears during OTP step)
                if (_otpSent) ...[
                  const SizedBox(height: 18),
                  CustomCard(
                    backgroundColor: AppColors.primaryLight.withOpacity(0.4),
                    child: Column(
                      crossAxisAlignment: CrossAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Tracked Admitted Patient',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryDark,
                                fontSize: 13,
                              ),
                            ),
                            StatusBadge(
                              label: _detectedRole == CaregiverRole.primary ? 'Primary Access' : 'Family Read-Only',
                              type: _detectedRole == CaregiverRole.primary ? BadgeType.success : BadgeType.neutral,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              AppConstants.demoPatientName,
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Age: ${AppConstants.demoPatientAge}',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: const [
                            _IdChip(title: 'Patient ID', val: AppConstants.demoPatientId, color: AppColors.primary),
                            SizedBox(width: 8),
                            _IdChip(title: 'Patient Phone', val: AppConstants.demoPatientPhone, color: AppColors.secondary),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Divider(),
                        const SizedBox(height: 6),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _DetailRow('Logging User', _phoneController.text),
                            _DetailRow('Access Granted', _detectedRole == CaregiverRole.primary ? 'Full Access' : 'Read-Only Access'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    decoration: const InputDecoration(
                      labelText: 'Enter 6-Digit Phone OTP',
                      prefixIcon: Icon(Icons.lock_clock_outlined),
                      counterText: '',
                    ),
                  ),
                ],

                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : (_otpSent ? _verifyAndRegister : _sendOtp),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text(_otpSent ? 'Verify OTP & Enter App' : 'Send Phone OTP'),
                  ),
                ),
                if (_otpSent) ...[
                  const SizedBox(height: 8),
                  Center(
                    child: TextButton(
                      onPressed: () => setState(() => _otpSent = false),
                      child: const Text('Change Phone or Admission ID'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IdChip extends StatelessWidget {
  final String title;
  final String val;
  final Color color;

  const _IdChip({Key? key, required this.title, required this.val, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Text(
        '$title: $val',
        style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String val;

  const _DetailRow(this.label, this.val, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          children: [
            TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
            TextSpan(text: val, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
