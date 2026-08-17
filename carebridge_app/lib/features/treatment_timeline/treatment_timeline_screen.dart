import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/custom_card.dart';
import '../../core/widgets/status_badge.dart';

class TreatmentTimelineScreen extends StatelessWidget {
  const TreatmentTimelineScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final updates = [
      {
        'date': 'Today, 09:30 AM',
        'doctor': 'Dr. Aris Thorne (Cardiology)',
        'note': 'Morning rounds completed. Chest x-ray shows clearing. Continue IV Ceftriaxone. Taper oxygen flow.',
        'vitals': 'BP: 120/80 mmHg | HR: 74 bpm | SpO2: 98%',
        'dept': 'Cardiology',
      },
      {
        'date': 'Yesterday, 06:00 PM',
        'doctor': 'Dr. Elena Rostova (Pulmonology)',
        'note': 'Nebulization completed. Patient reported reduced breathlessness. Recommended light walking in corridor.',
        'vitals': 'BP: 124/82 mmHg | HR: 78 bpm | SpO2: 97%',
        'dept': 'Pulmonology',
      },
      {
        'date': '13 Aug 2026, 11:00 AM',
        'doctor': 'Dr. Marcus Vance (Internal Med)',
        'note': 'Admitted to ICU Room 304 following acute cardiac observation. Initial blood panel requested.',
        'vitals': 'BP: 138/90 mmHg | HR: 88 bpm | Temp: 99.1°F',
        'dept': 'ICU Dept',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Treatment Timeline'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: updates.length,
        itemBuilder: (context, index) {
          final item = updates[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: Row(
              crossAxisAlignment: CrossAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    if (index != updates.length - 1)
                      Container(
                        width: 2,
                        height: 120,
                        color: AppColors.border,
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomCard(
                    child: Column(
                      crossAxisAlignment: CrossAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item['date']!,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            StatusBadge(label: item['dept']!, type: BadgeType.info),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item['doctor']!,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item['note']!,
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item['vitals']!,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
