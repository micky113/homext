class UserEntity {
  final String uid;
  final String name;
  final String role; // "RESIDENT" or "GUARD"
  final Map<String, dynamic> metadata; // e.g. flatNumber or gateNumber
  final String fcmToken;

  UserEntity({
    required this.uid,
    required this.name,
    required this.role,
    required this.metadata,
    required this.fcmToken,
  });

  String get flatNumber => metadata['flatNumber'] ?? '';
  String get gateNumber => metadata['gateNumber'] ?? '';

  bool get isResident => role == 'RESIDENT';
  bool get isGuard => role == 'GUARD';
}
