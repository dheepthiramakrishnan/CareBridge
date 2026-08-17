import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/custom_card.dart';
import '../../core/widgets/status_badge.dart';

class DocumentsScreen extends StatelessWidget {
  const DocumentsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final docs = [
      {'title': 'Hospital Admission Authorization Form', 'category': 'Admission', 'date': '13 Aug 2026', 'size': '1.2 MB'},
      {'title': 'Caregiver Government ID Proof (Aadhaar)', 'category': 'Identity', 'date': '13 Aug 2026', 'size': '850 KB'},
      {'title': 'Insurance Pre-Auth Clearance Letter', 'category': 'Insurance', 'date': '14 Aug 2026', 'size': '2.4 MB'},
      {'title': 'ECG & Echocardiogram Diagnostic Report', 'category': 'Diagnostics', 'date': '14 Aug 2026', 'size': '4.1 MB'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Documents & Records'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Document upload dialog opened')),
          );
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.cloud_upload_outlined, color: Colors.white),
        label: const Text('Upload Doc', style: TextStyle(color: Colors.white)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: docs.length,
        itemBuilder: (context, index) {
          final d = docs[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: CustomCard(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.infoLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.insert_drive_file, color: AppColors.primary, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAlignment.start,
                      children: [
                        Text(d['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 4),
                        Text('${d['category']} • ${d['date']} • ${d['size']}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  const StatusBadge(label: 'Verified', type: BadgeType.success),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
