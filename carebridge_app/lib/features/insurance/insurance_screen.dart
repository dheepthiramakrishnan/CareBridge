import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/custom_card.dart';
import '../../core/widgets/status_badge.dart';

class InsuranceScreen extends StatelessWidget {
  const InsuranceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const currentStep = 2; // Approved phase (0: Submitted, 1: Under Review, 2: Approved, 3: Settled)
    final stages = [
      {'title': 'Submitted', 'desc': 'Claim details sent to Star Health Insurance', 'date': '13 Aug 10:00 AM'},
      {'title': 'Under Review', 'desc': 'Medical officer verifying hospital records', 'date': '13 Aug 02:30 PM'},
      {'title': 'Approved', 'desc': 'Pre-authorization granted for ₹50,000', 'date': '14 Aug 09:15 AM'},
      {'title': 'Settled', 'desc': 'Final discharge payout settlement', 'date': 'Pending Discharge'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Insurance Claim Tracking'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAlignment.start,
          children: [
            // Policy Card
            CustomCard(
              backgroundColor: AppColors.surface,
              child: Column(
                crossAxisAlignment: CrossAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Star Health Cashless Mediclaim', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      StatusBadge(label: 'Pre-Approved', type: BadgeType.success),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('Policy No: SH-9948210394 | Claim Ref: CLM-2026-778', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Requested Claim Amount', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      Text('₹60,000.00', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Pre-Approved Sum', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      Text('₹50,000.00', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.success, fontSize: 15)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Step Pipeline Visualizer
            const Text('Claim Workflow Timeline', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: stages.length,
              itemBuilder: (context, index) {
                final isPassed = index <= currentStep;
                final isCurrent = index == currentStep;
                final stage = stages[index];

                return Row(
                  crossAxisAlignment: CrossAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: isPassed ? AppColors.primary : AppColors.surfaceVariant,
                            shape: BoxShape.circle,
                            border: isCurrent ? Border.all(color: AppColors.primaryLight, width: 4) : null,
                          ),
                          child: Icon(
                            isPassed ? Icons.check : Icons.circle,
                            size: 16,
                            color: isPassed ? Colors.white : AppColors.textMuted,
                          ),
                        ),
                        if (index != stages.length - 1)
                          Container(
                            width: 3,
                            height: 60,
                            color: isPassed ? AppColors.primary : AppColors.border,
                          ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  stage['title']!,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                                    color: isPassed ? AppColors.textPrimary : AppColors.textMuted,
                                  ),
                                ),
                                Text(
                                  stage['date']!,
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              stage['desc']!,
                              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
