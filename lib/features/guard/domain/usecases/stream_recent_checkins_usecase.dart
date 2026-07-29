import '../../domain/entities/checkin_entity.dart';
import '../../domain/repositories/guard_repository.dart';

class StreamRecentCheckinsUseCase {
  final GuardRepository _repository;

  StreamRecentCheckinsUseCase(this._repository);

  Stream<List<CheckInEntity>> call() {
    return _repository.streamRecentCheckins();
  }
}
