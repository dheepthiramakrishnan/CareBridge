import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/custom_card.dart';
import '../../core/widgets/status_badge.dart';

class DashboardScreen extends StatelessWidget {
  final CaregiverRole currentRole;
  final Function(int index) onNavigate;

  const DashboardScreen({
    Key? key,
    required this.currentRole,
    required this.onNavigate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isPrimary = currentRole == CaregiverRole.primary;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAlignment.start,
          children: const [
            Text(AppConstants.appName),
            Text(
              'HMS Patient Tracker Connected',
              style: TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.map_outlined),
            onPressed: () => onNavigate(7), // Hospital Map Index
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined),
            onPressed: () => onNavigate(8),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => onNavigate(9),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAlignment.start,
          children: [
            // Header Text: Primary Caregiver
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.person_pin, size: 20, color: AppColors.primary),
                      SizedBox(width: 8),
                      Text(
                        'Primary Caregiver',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                      ),
                    ],
                  ),
                  Text(
                    '${AppConstants.demoCaregiverName} (${AppConstants.demoCaregiverId})',
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),

            // Admitted Patient Demographics Card
            CustomCard(
              backgroundColor: AppColors.primary,
              child: Column(
                crossAxisAlignment: CrossAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: Colors.white24,
                            radius: 22,
                            child: Icon(Icons.badge, color: Colors.white, size: 26),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAlignment.start,
                            children: const [
                              Text(
                                AppConstants.demoPatientName,
                                style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Age: ${AppConstants.demoPatientAge} • ${AppConstants.demoPatientGender} (${AppConstants.demoPatientBloodGroup})',
                                style: TextStyle(fontSize: 12, color: Colors.white70),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const StatusBadge(
                        label: 'Admitted Patient',
                        type: BadgeType.info,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Patient & Caregiver Identifiers Grid
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            _IdTag(title: 'Patient ID', value: AppConstants.demoPatientId),
                            _IdTag(title: 'Patient Phone', value: AppConstants.demoPatientPhone),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            _IdTag(title: 'Admission ID', value: AppConstants.demoAdmissionId),
                            _IdTag(title: 'Caregiver ID', value: AppConstants.demoCaregiverId),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      _PatientInfoChip(label: 'Hospital', val: 'St. Jude Memorial'),
                      _PatientInfoChip(label: 'Location', val: AppConstants.demoRoom),
                      _PatientInfoChip(label: 'Doctor', val: 'Dr. Aris Thorne'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Quick Action Modules Grid (Added Hospital Map tile)
            const Text(
              'Patient Care Modules',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              children: [
                _buildActionTile(context, 'Timeline', Icons.timeline, AppColors.primary, () => onNavigate(1)),
                _buildActionTile(context, 'Lab Reports', Icons.science, AppColors.secondary, () => onNavigate(2)),
                _buildActionTile(context, 'Pharmacy', Icons.medication, AppColors.accent, () => onNavigate(3)),
                _buildActionTile(context, 'Billing', Icons.receipt_long, AppColors.warning, () => onNavigate(4)),
                _buildActionTile(context, 'Insurance', Icons.shield, AppColors.success, () => onNavigate(5)),
                _buildActionTile(context, 'Documents', Icons.folder_shared, AppColors.info, () => onNavigate(6)),
                _buildActionTile(context, 'Hospital Map', Icons.map, Colors.purple, () => onNavigate(7)),
                _buildActionTile(context, 'Family', Icons.group, Colors.indigo, () => onNavigate(10)),
              ],
            ),
            const SizedBox(height: 20),

            // Doctor Instruction
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Latest Doctor Instruction',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => onNavigate(1),
                  child: const Text('View All'),
                ),
              ],
            ),
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'Dr. Aris Thorne (Cardiology)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      StatusBadge(label: 'Today 09:30 AM', type: BadgeType.info),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Patient responding well to IV antibiotics. SpO2 stable at 98%. Maintain light liquid diet and monitor blood pressure every 4 hours.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: const [
                      _VitalChip(icon: Icons.favorite, label: 'BP: 120/80'),
                      SizedBox(width: 8),
                      _VitalChip(icon: Icons.air, label: 'SpO2: 98%'),
                      SizedBox(width: 8),
                      _VitalChip(icon: Icons.thermostat, label: 'Temp: 98.6°F'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Billing Quick Card
            CustomCard(
              backgroundColor: AppColors.warningLight.withOpacity(0.3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAlignment.start,
                    children: const [
                      Text('Outstanding Hospital Balance', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      SizedBox(height: 4),
                      Text('₹14,500.00', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: isPrimary ? () => onNavigate(4) : null,
                    child: Text(isPrimary ? 'Pay Now' : 'Read Only'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return CustomCard(
      padding: const EdgeInsets.all(6),
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _IdTag extends StatelessWidget {
  final String title;
  final String value;

  const _IdTag({Key? key, required this.title, required this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('$title: ', style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _PatientInfoChip extends StatelessWidget {
  final String label;
  final String val;

  const _PatientInfoChip({Key? key, required this.label, required this.val}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        Text(val, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
      ],
    );
  }
}

class _VitalChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _VitalChip({Key? key, required this.icon, required this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
