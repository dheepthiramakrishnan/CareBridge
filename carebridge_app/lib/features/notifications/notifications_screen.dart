import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/custom_card.dart';
import '../../core/widgets/status_badge.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final notifications = [
      {
        'title': 'New Doctor Treatment Instruction',
        'body': 'Dr. Aris Thorne updated morning treatment instructions for Eleanor Vance.',
        'time': '10 mins ago',
        'type': 'Treatment',
        'icon': Icons.medical_information,
        'badgeType': BadgeType.info,
      },
      {
        'title': 'Lab Report Uploaded',
        'body': 'Complete Blood Count (CBC) report is now available for view/download.',
        'time': '1 hour ago',
        'type': 'Laboratory',
        'icon': Icons.science,
        'badgeType': BadgeType.success,
      },
      {
        'title': 'Insurance Claim Pre-Approved',
        'body': 'Star Health Mediclaim approved cashless amount of ₹50,000.',
        'time': 'Yesterday',
        'type': 'Insurance',
        'icon': Icons.shield,
        'badgeType': BadgeType.success,
      },
      {
        'title': 'New Hospital Bill Generated',
        'body': 'Daily ICU and medication charge updated. Payable balance: ₹14,500.',
        'time': '2 days ago',
        'type': 'Billing',
        'icon': Icons.receipt,
        'badgeType': BadgeType.warning,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications & HMS Alerts'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final n = notifications[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: CustomCard(
              child: Row(
                crossAxisAlignment: CrossAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(n['icon'] as IconData, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                n['title'] as String,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ),
                            Text(n['time'] as String, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          n['body'] as String,
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 8),
                        StatusBadge(label: n['type'] as String, type: n['badgeType'] as BadgeType),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
