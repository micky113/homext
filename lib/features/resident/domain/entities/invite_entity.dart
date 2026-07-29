class InviteEntity {
  final String id;
  final String visitorName;
  final String purpose;
  final DateTime inviteDate;
  final String inviteCode;
  final String flatNumber;
  final String hostName;

  InviteEntity({
    required this.id,
    required this.visitorName,
    required this.purpose,
    required this.inviteDate,
    required this.inviteCode,
    required this.flatNumber,
    required this.hostName,
  });
}
