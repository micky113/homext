import '../../../resident/domain/entities/invite_entity.dart';
import '../repositories/guard_repository.dart';

class StreamPreApprovedInvitesUseCase {
  final GuardRepository _repository;

  StreamPreApprovedInvitesUseCase(this._repository);

  Stream<List<InviteEntity>> call() {
    return _repository.streamPreApprovedInvites();
  }
}
