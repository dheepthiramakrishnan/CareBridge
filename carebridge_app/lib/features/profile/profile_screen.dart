import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/custom_card.dart';
import '../../core/widgets/status_badge.dart';

class ProfileScreen extends StatelessWidget {
  final CaregiverRole currentRole;
  final VoidCallback onLogout;

  const ProfileScreen({
    Key? key,
    required this.currentRole,
    required this.onLogout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile & Identity Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAlignment.start,
          children: [
            // CARD 1: Caregiver App Account
            const Text('Caregiver App User (You)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            CustomCard(
              child: Column(
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 28,
                        backgroundColor: AppColors.primaryLight,
                        child: Icon(Icons.person, size: 32, color: AppColors.primary),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAlignment.start,
                          children: [
                            const Text(AppConstants.demoCaregiverName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                            const Text('${AppConstants.demoCaregiverPhone} • ${AppConstants.demoCaregiverRelation}', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            const SizedBox(height: 4),
                            StatusBadge(
                              label: AppConstants.getRoleName(currentRole),
                              type: currentRole == CaregiverRole.primary ? BadgeType.success : BadgeType.neutral,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      _ProfileIdChip(label: 'Caregiver ID', val: AppConstants.demoCaregiverId),
                      _ProfileIdChip(label: 'Phone Auth', val: 'OTP Verified'),
                      _ProfileIdChip(label: 'Session', val: 'Active'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // CARD 2: Admitted Patient Details (Person Being Tracked)
            const Text('Admitted Patient Details (Tracked by Caregiver)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            CustomCard(
              backgroundColor: AppColors.surface,
              border: Border.all(color: AppColors.primary, width: 1.5),
              child: Column(
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 26,
                        backgroundColor: AppColors.primaryLight,
                        child: Icon(Icons.local_hospital, size: 30, color: AppColors.primary),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAlignment.start,
                          children: const [
                            Text(
                              AppConstants.demoPatientName,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            Text(
                              'Age: ${AppConstants.demoPatientAge} • ${AppConstants.demoPatientGender} (${AppConstants.demoPatientBloodGroup})',
                              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      const StatusBadge(label: 'Admitted', type: BadgeType.success),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),
                  _SettingRow('Patient ID', AppConstants.demoPatientId),
                  const Divider(),
                  _SettingRow('Patient Phone Number', AppConstants.demoPatientPhone),
                  const Divider(),
                  _SettingRow('Hospital Admission ID', AppConstants.demoAdmissionId),
                  const Divider(),
                  _SettingRow('Hospital & Ward', '${AppConstants.demoHospital} (${AppConstants.demoRoom})'),
                  const Divider(),
                  _SettingRow('Attending Doctor', AppConstants.demoDoctor),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // HMS Integration Technical Info
            const Text('HMS System Connection', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            CustomCard(
              child: Column(
                children: const [
                  _SettingRow('HMS Host', 'St. Jude HMS (v4.2.1)'),
                  Divider(),
                  _SettingRow('API Bridge Endpoint', AppConstants.apiBaseUrl),
                  Divider(),
                  _SettingRow('Authentication', 'Firebase Phone OTP'),
                  Divider(),
                  _SettingRow('Push Notification Channel', 'FCM Active'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  side: const BorderSide(color: AppColors.danger),
                ),
                onPressed: onLogout,
                icon: const Icon(Icons.logout),
                label: const Text('Sign Out Caregiver Account'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileIdChip extends StatelessWidget {
  final String label;
  final String val;

  const _ProfileIdChip({Key? key, required this.label, required this.val}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        Text(val, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
      ],
    );
  }
}

class _SettingRow extends StatelessWidget {
  final String title;
  final String val;

  const _SettingRow(this.title, this.val, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          Text(val, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }
}
