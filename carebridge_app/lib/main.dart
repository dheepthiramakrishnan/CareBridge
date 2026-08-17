import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'features/auth/auth_screen.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/treatment_timeline/treatment_timeline_screen.dart';
import 'features/lab_reports/lab_reports_screen.dart';
import 'features/prescriptions/prescriptions_screen.dart';
import 'features/billing/billing_screen.dart';
import 'features/insurance/insurance_screen.dart';
import 'features/documents/documents_screen.dart';
import 'features/hospital_map/hospital_map_screen.dart';
import 'features/family_access/family_access_screen.dart';
import 'features/notifications/notifications_screen.dart';
import 'features/profile/profile_screen.dart';

void main() {
  runApp(const CareBridgeApp());
}

class CareBridgeApp extends StatefulWidget {
  const CareBridgeApp({Key? key}) : super(key: key);

  @override
  State<CareBridgeApp> createState() => _CareBridgeAppState();
}

class _CareBridgeAppState extends State<CareBridgeApp> {
  bool _isAuthenticated = false;
  int _currentIndex = 0;
  CaregiverRole _currentRole = CaregiverRole.primary;

  void _handleLoginSuccess(CaregiverRole role) {
    setState(() {
      _currentRole = role;
      _isAuthenticated = true;
    });
  }

  void _handleRoleSwitch(CaregiverRole newRole) {
    setState(() {
      _currentRole = newRole;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: _isAuthenticated
          ? Scaffold(
              body: IndexedStack(
                index: _currentIndex,
                children: [
                  DashboardScreen(
                    currentRole: _currentRole,
                    onNavigate: (index) => setState(() => _currentIndex = index),
                  ),
                  const TreatmentTimelineScreen(),
                  const LabReportsScreen(),
                  const PrescriptionsScreen(),
                  BillingScreen(currentRole: _currentRole),
                  const InsuranceScreen(),
                  const DocumentsScreen(),
                  const HospitalMapScreen(),
                  FamilyAccessScreen(
                    currentRole: _currentRole,
                    onRoleSwitched: _handleRoleSwitch,
                  ),
                  const NotificationsScreen(),
                  ProfileScreen(
                    currentRole: _currentRole,
                    onLogout: () => setState(() => _isAuthenticated = false),
                  ),
                ],
              ),
              bottomNavigationBar: BottomNavigationBar(
                currentIndex: _currentIndex > 6 ? 0 : _currentIndex,
                onTap: (index) => setState(() => _currentIndex = index),
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.dashboard_outlined),
                    activeIcon: Icon(Icons.dashboard),
                    label: 'Dashboard',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.timeline),
                    label: 'Timeline',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.science_outlined),
                    activeIcon: Icon(Icons.science),
                    label: 'Reports',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.medication_outlined),
                    activeIcon: Icon(Icons.medication),
                    label: 'Pharmacy',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.receipt_long_outlined),
                    activeIcon: Icon(Icons.receipt_long),
                    label: 'Billing',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.shield_outlined),
                    activeIcon: Icon(Icons.shield),
                    label: 'Insurance',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.map_outlined),
                    activeIcon: Icon(Icons.map),
                    label: 'Map',
                  ),
                ],
              ),
            )
          : AuthScreen(
              onLoginSuccess: _handleLoginSuccess,
            ),
    );
  }
}
