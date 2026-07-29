import '../../domain/entities/checkin_entity.dart';
import '../../domain/repositories/guard_repository.dart';

class CheckInVisitorUseCase {
  final GuardRepository _repository;

  CheckInVisitorUseCase(this._repository);

  Future<CheckInEntity> call({
    required String visitorName,
    required String purpose,
    required String flatNumber,
    required String gateNumber,
    required String guardId,
  }) {
    return _repository.checkInVisitor(
      visitorName: visitorName,
      purpose: purpose,
      flatNumber: flatNumber,
      gateNumber: gateNumber,
      guardId: guardId,
    );
  }
}
