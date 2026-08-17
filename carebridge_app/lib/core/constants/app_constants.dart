enum CaregiverRole {
  primary,
  family,
}

enum InsuranceStatus {
  submitted,
  underReview,
  approved,
  rejected,
  settled,
}

enum PaymentMethod {
  upi,
  debitCard,
  creditCard,
  netBanking,
}

enum PaymentStatus {
  pending,
  paid,
  failed,
  refunded,
}

class AppConstants {
  static const String appName = 'CareBridge';
  static const String appTagline = 'Caregiver Platform for Tracking Admitted Patients';
  static const String apiBaseUrl = 'http://localhost:8080/api/v1';

  // Tracked Patient Information (Admitted Person)
  static const String demoPatientName = 'Eleanor Vance';
  static const String demoPatientId = 'PAT-8842-EV';
  static const String demoPatientAge = '58 Years';
  static const String demoPatientGender = 'Female';
  static const String demoPatientBloodGroup = 'A+';
  static const String demoPatientPhone = '+91 98111 22334';
  static const String demoAdmissionId = 'HMS-2026-8842';
  static const String demoHospital = 'St. Jude Memorial Hospital';
  static const String demoRoom = 'ICU Room 304';
  static const String demoDoctor = 'Dr. Aris Thorne (Cardiology)';

  // Caregiver Information (App User Tracking the Patient)
  static const String demoCaregiverName = 'Sarah Vance';
  static const String demoCaregiverId = 'CG-991823';
  static const String demoCaregiverPhone = '+91 98765 43210';
  static const String demoCaregiverRelation = 'Daughter (Primary Caregiver)';

  static String getRoleName(CaregiverRole role) {
    switch (role) {
      case CaregiverRole.primary:
        return 'Primary Caregiver (Full Access)';
      case CaregiverRole.family:
        return 'Family Member (Read-Only)';
    }
  }

  static String getInsuranceStatusText(InsuranceStatus status) {
    switch (status) {
      case InsuranceStatus.submitted:
        return 'Submitted';
      case InsuranceStatus.underReview:
        return 'Under Review';
      case InsuranceStatus.approved:
        return 'Approved';
      case InsuranceStatus.rejected:
        return 'Rejected';
      case InsuranceStatus.settled:
        return 'Settled';
    }
  }
}
