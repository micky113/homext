import '../../domain/entities/invite_entity.dart';
import '../../domain/repositories/resident_repository.dart';

class CreateInviteUseCase {
  final ResidentRepository _repository;

  CreateInviteUseCase(this._repository);

  Future<InviteEntity> call({
    required String userId,
    required String visitorName,
    required String purpose,
    required DateTime inviteDate,
    required String flatNumber,
    required String hostName,
  }) {
    return _repository.createInvite(
      userId: userId,
      visitorName: visitorName,
      purpose: purpose,
      inviteDate: inviteDate,
      flatNumber: flatNumber,
      hostName: hostName,
    );
  }
}
