import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/custom_card.dart';
import '../../core/widgets/status_badge.dart';

class PrescriptionsScreen extends StatefulWidget {
  const PrescriptionsScreen({Key? key}) : super(key: key);

  @override
  State<PrescriptionsScreen> createState() => _PrescriptionsScreenState();
}

class _PrescriptionsScreenState extends State<PrescriptionsScreen> {
  final List<Map<String, dynamic>> _medications = [
    {
      'id': 'MED-01',
      'name': 'Ceftriaxone 1g Injection (IV)',
      'dosage': '1g once daily (09:00 AM)',
      'duration': '5 Days (Day 3 of 5)',
      'isCollected': false,
      'collectionStatus': 'Ready for Collection',
      'pharmacyCounter': 'Main Pharmacy - Ground Floor Counter 3',
      'pickupToken': 'TOKEN #PH-4082',
      'instructions': 'Administer slowly via IV line under nursing supervision.',
      'prescribedBy': 'Dr. Aris Thorne',
      'collectedAt': null,
    },
    {
      'id': 'MED-02',
      'name': 'Atorvastatin 20mg Tablet',
      'dosage': '1 tablet at bedtime (09:00 PM)',
      'duration': '30 Tablets Pack',
      'isCollected': true,
      'collectionStatus': 'Collected by Caregiver',
      'pharmacyCounter': 'Main Pharmacy - Ground Floor Counter 3',
      'pickupToken': 'TOKEN #PH-4079',
      'instructions': 'Take after dinner with water.',
      'prescribedBy': 'Dr. Aris Thorne',
      'collectedAt': 'Today at 10:15 AM',
    },
    {
      'id': 'MED-03',
      'name': 'Budecort 1mg Nebulizer Respules',
      'dosage': 'Twice daily (10:00 AM, 08:00 PM)',
      'duration': '1 Box (5 Respules)',
      'isCollected': true,
      'collectionStatus': 'Collected by Caregiver',
      'pharmacyCounter': 'ICU Satellite Pharmacy - 3rd Floor',
      'pickupToken': 'TOKEN #PH-3912',
      'instructions': 'Nebulize with normal saline over 10 minutes.',
      'prescribedBy': 'Dr. Elena Rostova',
      'collectedAt': 'Yesterday at 04:30 PM',
    },
  ];

  void _toggleCollection(int index) {
    setState(() {
      final isCurrentlyCollected = _medications[index]['isCollected'] as bool;
      if (isCurrentlyCollected) {
        _medications[index]['isCollected'] = false;
        _medications[index]['collectionStatus'] = 'Ready for Collection';
        _medications[index]['collectedAt'] = null;
      } else {
        _medications[index]['isCollected'] = true;
        _medications[index]['collectionStatus'] = 'Collected by Caregiver';
        _medications[index]['collectedAt'] = 'Just Now (${TimeOfDay.now().format(context)})';
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _medications[index]['isCollected']
              ? 'Marked as Collected by Caregiver at Pharmacy Counter'
              : 'Status updated to Ready for Collection',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pendingCount = _medications.where((m) => !(m['isCollected'] as bool)).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hospital Pharmacy & Medications'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAlignment.start,
          children: [
            // Pharmacy Collection Center Banner
            CustomCard(
              backgroundColor: AppColors.primary,
              child: Column(
                crossAxisAlignment: CrossAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.local_pharmacy, color: Colors.white, size: 24),
                          SizedBox(width: 10),
                          Text(
                            'Caregiver Pharmacy Pickup',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: pendingCount > 0 ? AppColors.warning : AppColors.success,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          pendingCount > 0 ? '$pendingCount Ready for Pickup' : 'All Collected',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Caregivers can collect prescribed medicines directly from Ground Floor Counter 3 using the Token ID below.',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('Pickup Counter: Ground Floor Counter 3', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                        Text('Token: PH-4082', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Prescriptions & Collection Status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _medications.length,
              itemBuilder: (context, index) {
                final m = _medications[index];
                final isCollected = m['isCollected'] as bool;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 14.0),
                  child: CustomCard(
                    border: Border.all(
                      color: isCollected ? AppColors.border : AppColors.warning,
                      width: isCollected ? 1 : 1.5,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                m['name'] as String,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                            StatusBadge(
                              label: m['collectionStatus'] as String,
                              type: isCollected ? BadgeType.success : BadgeType.warning,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        Row(
                          children: [
                            const Icon(Icons.schedule, size: 16, color: AppColors.primary),
                            const SizedBox(width: 6),
                            Text(m['dosage'] as String, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.inventory_2_outlined, size: 16, color: AppColors.textSecondary),
                            const SizedBox(width: 6),
                            Text(m['duration'] as String, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Collection Location & Token Info
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    m['pharmacyCounter'] as String,
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                  ),
                                  Text(
                                    m['pickupToken'] as String,
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                                  ),
                                ],
                              ),
                              if (isCollected && m['collectedAt'] != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Collected: ${m['collectedAt']}',
                                  style: const TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),

                        Text(
                          'Prescribed by: ${m['prescribedBy']}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 12),

                        // Interactive Caregiver Pickup Action Button
                        SizedBox(
                          width: double.infinity,
                          child: isCollected
                              ? OutlinedButton.icon(
                                  onPressed: () => _toggleCollection(index),
                                  icon: const Icon(Icons.check_circle, size: 18, color: AppColors.success),
                                  label: const Text('Collected by Caregiver (Click to Reset)'),
                                )
                              : ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.warning,
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () => _toggleCollection(index),
                                  icon: const Icon(Icons.shopping_bag_outlined, size: 18),
                                  label: const Text('Mark as Collected at Pharmacy'),
                                ),
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
}
