import '../../../guard/domain/entities/checkin_entity.dart';
import '../entities/invite_entity.dart';
import '../entities/notice_entity.dart';

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
  Stream<List<NoticeEntity>> streamNotices(String societyId);
  Future<void> postNotice({
    required String societyId,
    required String title,
    required String content,
    required String postedBy,
  });
  Future<void> payDues({required String userId});
  Future<void> confirmPayment({required String userId});
  Future<void> rejectPayment({required String userId});
  Future<void> submitPaymentVerification({required String userId, required String remarks, required String amountPaid});
  Stream<String> streamMonthlyMaintenance(String societyId);
  Future<void> updateMonthlyMaintenance({required String societyId, required String amount});
  Future<void> addCustomCharge({required String userId, required String title, required String amount});
  Future<void> generateMonthlyBills({required String societyId});
  Future<void> billSpecialCharge({required String societyId, required String title, required String amount});
}
