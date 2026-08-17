import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/custom_card.dart';
import '../../core/widgets/status_badge.dart';

class LabReportsScreen extends StatelessWidget {
  const LabReportsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final reports = [
      {
        'title': 'Complete Blood Count (CBC)',
        'date': '14 Aug 2026',
        'status': 'Normal',
        'badgeType': BadgeType.success,
        'doctor': 'Pathology Dept',
        'ref': 'LAB-9921',
      },
      {
        'title': 'Cardiac Enzymes (Troponin T)',
        'date': '14 Aug 2026',
        'status': 'Elevated (Monitored)',
        'badgeType': BadgeType.warning,
        'doctor': 'Biochemistry Dept',
        'ref': 'LAB-9925',
      },
      {
        'title': 'High-Resolution Chest CT Scan',
        'date': '13 Aug 2026',
        'status': 'Completed',
        'badgeType': BadgeType.info,
        'doctor': 'Radiology Dept',
        'ref': 'RAD-4012',
      },
      {
        'title': 'Serum Electrolytes & Renal Panel',
        'date': '13 Aug 2026',
        'status': 'Normal',
        'badgeType': BadgeType.success,
        'doctor': 'Pathology Dept',
        'ref': 'LAB-9910',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laboratory & Diagnostic Reports'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: reports.length,
        itemBuilder: (context, index) {
          final r = reports[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: CustomCard(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.picture_as_pdf, color: AppColors.primary, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAlignment.start,
                      children: [
                        Text(
                          r['title'] as String,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${r['doctor']} • ${r['date']} • Ref: ${r['ref']}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 6),
                        StatusBadge(
                          label: r['status'] as String,
                          type: r['badgeType'] as BadgeType,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.file_download_outlined, color: AppColors.primary),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Downloading report PDF: ${r['ref']}')),
                      );
                    },
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
