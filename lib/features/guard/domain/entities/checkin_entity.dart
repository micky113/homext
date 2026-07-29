class CheckInEntity {
  final String id;
  final String visitorName;
  final String purpose;
  final String flatNumber;
  final String gateNumber;
  final String guardId;
  final DateTime timestamp;
  final String status; // "PENDING", "APPROVED", "DENIED"

  CheckInEntity({
    required this.id,
    required this.visitorName,
    required this.purpose,
    required this.flatNumber,
    required this.gateNumber,
    required this.guardId,
    required this.timestamp,
    required this.status,
  });

  bool get isPending => status == 'PENDING';
  bool get isApproved => status == 'APPROVED';
  bool get isDenied => status == 'DENIED';
  bool get isExited => status == 'EXITED';
}
