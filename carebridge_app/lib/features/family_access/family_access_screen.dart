import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/custom_card.dart';
import '../../core/widgets/status_badge.dart';

class FamilyAccessScreen extends StatefulWidget {
  final CaregiverRole currentRole;
  final Function(CaregiverRole newRole) onRoleSwitched;

  const FamilyAccessScreen({
    Key? key,
    required this.currentRole,
    required this.onRoleSwitched,
  }) : super(key: key);

  @override
  State<FamilyAccessScreen> createState() => _FamilyAccessScreenState();
}

class _FamilyAccessScreenState extends State<FamilyAccessScreen> {
  final List<Map<String, String>> _familyMembers = [
    {
      'name': 'Sarah Vance (You)',
      'phone': '+91 98765 43210',
      'relation': 'Daughter',
      'role': 'Primary Caregiver',
      'isPrimary': 'true',
    },
    {
      'name': 'David Vance',
      'phone': '+91 98123 76543',
      'relation': 'Son',
      'role': 'Family Member (Read-Only)',
      'isPrimary': 'false',
    },
    {
      'name': 'Clara Vance',
      'phone': '+91 99001 12233',
      'relation': 'Sister',
      'role': 'Family Member (Read-Only)',
      'isPrimary': 'false',
    },
  ];

  final _invitePhoneController = TextEditingController();
  final _inviteNameController = TextEditingController();

  void _showInviteModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
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
              const Text('Invite Family Member', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Invited family members get Read-Only access to patient timeline, reports, & prescriptions.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              TextField(
                controller: _inviteNameController,
                decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _invitePhoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Mobile Number (+91)', prefixIcon: Icon(Icons.phone)),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_inviteNameController.text.isNotEmpty) {
                      setState(() {
                        _familyMembers.add({
                          'name': _inviteNameController.text,
                          'phone': _invitePhoneController.text.isEmpty ? '+91 98000 00000' : _invitePhoneController.text,
                          'relation': 'Family Member',
                          'role': 'Family Member (Read-Only)',
                          'isPrimary': 'false',
                        });
                      });
                      _inviteNameController.clear();
                      _invitePhoneController.clear();
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Invitation sent successfully!')),
                      );
                    }
                  },
                  child: const Text('Send SMS Access Invite'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPrimary = widget.currentRole == CaregiverRole.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Access Management'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAlignment.start,
          children: [
            // Active Role Switcher Card (For Testing RBAC)
            CustomCard(
              backgroundColor: AppColors.primaryLight,
              child: Column(
                crossAxisAlignment: CrossAlignment.start,
                children: [
                  const Text('Role Access Simulator (RBAC Testing)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  const Text('Switch current session role to test Primary Caregiver vs Read-Only permissions.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ChoiceChip(
                        label: const Text('Primary Caregiver'),
                        selected: isPrimary,
                        onSelected: (val) {
                          if (val) widget.onRoleSwitched(CaregiverRole.primary);
                        },
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('Family Read-Only'),
                        selected: !isPrimary,
                        onSelected: (val) {
                          if (val) widget.onRoleSwitched(CaregiverRole.family);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Authorized Family Members', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                if (isPrimary)
                  OutlinedButton.icon(
                    onPressed: _showInviteModal,
                    icon: const Icon(Icons.person_add_alt_1, size: 18),
                    label: const Text('Invite'),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _familyMembers.length,
              itemBuilder: (context, index) {
                final mem = _familyMembers[index];
                final isMemPrimary = mem['isPrimary'] == 'true';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: CustomCard(
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: isMemPrimary ? AppColors.primary : AppColors.surfaceVariant,
                          child: Icon(
                            isMemPrimary ? Icons.star : Icons.person_outline,
                            color: isMemPrimary ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAlignment.start,
                            children: [
                              Text(mem['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              const SizedBox(height: 2),
                              Text('${mem['phone']} • ${mem['relation']}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                              const SizedBox(height: 6),
                              StatusBadge(
                                label: mem['role']!,
                                type: isMemPrimary ? BadgeType.success : BadgeType.neutral,
                              ),
                            ],
                          ),
                        ),
                        if (isPrimary && !isMemPrimary)
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: AppColors.danger),
                            onPressed: () {
                              setState(() => _familyMembers.removeAt(index));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Family access revoked')),
                              );
                            },
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
