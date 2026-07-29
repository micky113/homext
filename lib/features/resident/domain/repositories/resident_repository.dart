import '../../../guard/domain/entities/checkin_entity.dart';
import '../entities/invite_entity.dart';

abstract class ResidentRepository {
  Stream<List<InviteEntity>> streamInvites(String userId);
  Future<InviteEntity> createInvite({
    required String userId,
    required String visitorName,
    required String purpose,
    required DateTime inviteDate,
    required String flatNumber,
    required String hostName,
  });
  Stream<CheckInEntity> streamIncomingAlerts(String flatNumber);
  Stream<List<CheckInEntity>> streamVisitorHistory(String flatNumber);
  Future<void> respondToAlert({
    required String checkinId,
    required String status,
  });
}
