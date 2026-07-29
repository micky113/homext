import 'package:homext/features/resident/domain/entities/invite_entity.dart';
import '../entities/checkin_entity.dart';

abstract class GuardRepository {
  Stream<List<CheckInEntity>> streamRecentCheckins();
  Future<CheckInEntity> checkInVisitor({
    required String visitorName,
    required String purpose,
    required String flatNumber,
    required String gateNumber,
    required String guardId,
  });
  Stream<List<InviteEntity>> streamPreApprovedInvites();
  Future<CheckInEntity> checkInPreApprovedVisitor({
    required String inviteCode,
    required String gateNumber,
    required String guardId,
  });
  Future<void> exitVisitor(String checkinId);
}
