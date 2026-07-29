import '../entities/checkin_entity.dart';
import '../repositories/guard_repository.dart';

class CheckInPreApprovedVisitorUseCase {
  final GuardRepository _repository;

  CheckInPreApprovedVisitorUseCase(this._repository);

  Future<CheckInEntity> call({
    required String inviteCode,
    required String gateNumber,
    required String guardId,
  }) {
    return _repository.checkInPreApprovedVisitor(
      inviteCode: inviteCode,
      gateNumber: gateNumber,
      guardId: guardId,
    );
  }
}
