import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/custom_card.dart';
import '../../core/widgets/status_badge.dart';

class HospitalMapScreen extends StatefulWidget {
  const HospitalMapScreen({Key? key}) : super(key: key);

  @override
  State<HospitalMapScreen> createState() => _HospitalMapScreenState();
}

class _HospitalMapScreenState extends State<HospitalMapScreen> {
  String _selectedFloor = 'Ground Floor';

  final List<Map<String, String>> _allFacilities = [
    {
      'name': 'Main Reception & Help Desk',
      'category': 'Reception',
      'floor': 'Ground Floor',
      'location': 'Main Entrance Lobby',
      'icon': 'concierge_bell',
      'color': 'blue',
      'notes': '24/7 Visitor Passes & Patient Admission Inquiries',
    },
    {
      'name': 'Central Pharmacy Counter 3',
      'category': 'Pharmacy',
      'floor': 'Ground Floor',
      'location': 'Ground Floor East Wing',
      'icon': 'local_pharmacy',
      'color': 'green',
      'notes': 'Caregiver Medicine Pickup (Token PH-4082)',
    },
    {
      'name': 'Garden Court Canteen & Cafeteria',
      'category': 'Canteen',
      'floor': 'Ground Floor',
      'location': 'Garden Courtyard',
      'icon': 'restaurant',
      'color': 'orange',
      'notes': 'Fresh meals, coffee & caregiver seating (Open 24/7)',
    },
    {
      'name': 'Pathology & Radiology Labs',
      'category': 'Labs',
      'floor': '1st Floor',
      'location': '1st Floor Diagnostic Wing',
      'icon': 'science',
      'color': 'teal',
      'notes': 'Blood Sample Collection & CT/MRI Imaging',
    },
    {
      'name': 'Dr. Aris Thorne Cabin (204)',
      'category': 'Doctor Cabin',
      'floor': '2nd Floor',
      'location': '2nd Floor Cardiology OPD',
      'icon': 'person_search',
      'color': 'purple',
      'notes': 'Attending Cardiologist Consultation Office',
    },
    {
      'name': 'ICU Room 304 (Eleanor Vance)',
      'category': 'ICU',
      'floor': '3rd Floor',
      'location': '3rd Floor Critical Care Unit',
      'icon': 'local_hospital',
      'color': 'red',
      'notes': 'Tracked Patient Admitted Room - Elevator B Access',
    },
    {
      'name': 'Visitor & Caregiver Parking',
      'category': 'Parking',
      'floor': 'Basement B1',
      'location': 'Basement Level B1 & B2',
      'icon': 'directions_car',
      'color': 'indigo',
      'notes': 'Covered parking with 24/7 security & EV charging',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredFacilities = _allFacilities.where((f) => f['floor'] == _selectedFloor).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hospital Facility Map & Guide'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAlignment.start,
          children: [
            // Wayfinding Quick Route Card
            CustomCard(
              backgroundColor: AppColors.primary,
              child: Column(
                crossAxisAlignment: CrossAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.directions_walk, color: Colors.white, size: 24),
                      SizedBox(width: 10),
                      Text(
                        'Caregiver Quick Routes',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 8),
                  _buildRouteRow(
                    'To Patient Room (ICU 304)',
                    'Main Entrance → Elevator B → 3rd Floor Room 304',
                  ),
                  const SizedBox(height: 6),
                  _buildRouteRow(
                    'To Pharmacy Counter 3',
                    'Elevator A → Ground Floor East Wing Counter 3',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Floor Selector Filter Chips
            const Text(
              'Select Hospital Level',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  'Ground Floor',
                  '1st Floor',
                  '2nd Floor',
                  '3rd Floor',
                  'Basement B1',
                ].map((floor) {
                  final isSelected = _selectedFloor == floor;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(floor),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (val) {
                        if (val) setState(() => _selectedFloor = floor);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // Blueprint Floor Plan Visual Simulator
            CustomCard(
              backgroundColor: AppColors.surfaceVariant.withOpacity(0.6),
              child: Column(
                crossAxisAlignment: CrossAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$_selectedFloor Layout Map',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const StatusBadge(label: 'St. Jude Map v2.4', type: BadgeType.info),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Visual Map Layout Graphic
                  Container(
                    height: 160,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: 15, left: 20,
                          child: _buildMapPin(
                            _selectedFloor == 'Ground Floor' ? 'Reception' : (_selectedFloor == '3rd Floor' ? 'ICU 304' : 'Elevators'),
                            Colors.amber,
                          ),
                        ),
                        Positioned(
                          top: 15, right: 20,
                          child: _buildMapPin(
                            _selectedFloor == 'Ground Floor' ? 'Pharmacy' : (_selectedFloor == '1st Floor' ? 'Labs' : 'Restrooms'),
                            Colors.green,
                          ),
                        ),
                        Positioned(
                          bottom: 20, left: 20,
                          child: _buildMapPin(
                            _selectedFloor == 'Ground Floor' ? 'Canteen' : (_selectedFloor == '2nd Floor' ? 'Doctor 204' : 'Stairs'),
                            Colors.orange,
                          ),
                        ),
                        Positioned(
                          bottom: 20, right: 20,
                          child: _buildMapPin(
                            _selectedFloor == 'Basement B1' ? 'Parking B1' : 'Fire Exit',
                            Colors.blue,
                          ),
                        ),
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white12,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: Text(
                              '$_selectedFloor Main Corridor',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Facilities Directory List for selected floor
            Text(
              'Facilities on $_selectedFloor',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            if (filteredFacilities.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Center(
                  child: Text('No major public facilities listed on this level.'),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredFacilities.length,
                itemBuilder: (context, index) {
                  final f = filteredFacilities[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: CustomCard(
                      child: Row(
                        crossAxisAlignment: CrossAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _getCategoryColor(f['category']!).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _getCategoryIcon(f['category']!),
                              color: _getCategoryColor(f['category']!),
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAlignment.start,
                              children: [
                                Text(
                                  f['name']!,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${f['location']} • ${f['floor']}',
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  f['notes']!,
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                ),
                              ],
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

  Widget _buildRouteRow(String title, String path) {
    return Column(
      crossAxisAlignment: CrossAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600)),
        Text(path, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildMapPin(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.location_on, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String cat) {
    switch (cat) {
      case 'ICU': return Icons.local_hospital;
      case 'Pharmacy': return Icons.local_pharmacy;
      case 'Labs': return Icons.science;
      case 'Doctor Cabin': return Icons.person_search;
      case 'Reception': return Icons.concierge_bell;
      case 'Canteen': return Icons.restaurant;
      case 'Parking': return Icons.directions_car;
      default: return Icons.place;
    }
  }

  Color _getCategoryColor(String cat) {
    switch (cat) {
      case 'ICU': return AppColors.danger;
      case 'Pharmacy': return AppColors.success;
      case 'Labs': return AppColors.secondary;
      case 'Doctor Cabin': return AppColors.primary;
      case 'Reception': return AppColors.info;
      case 'Canteen': return AppColors.warning;
      case 'Parking': return Colors.indigo;
      default: return AppColors.primary;
    }
  }
}
