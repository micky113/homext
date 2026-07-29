import '../../domain/entities/invite_entity.dart';
import '../../domain/repositories/resident_repository.dart';

class StreamInvitesUseCase {
  final ResidentRepository _repository;

  StreamInvitesUseCase(this._repository);

  Stream<List<InviteEntity>> call(String userId) {
    return _repository.streamInvites(userId);
  }
}
