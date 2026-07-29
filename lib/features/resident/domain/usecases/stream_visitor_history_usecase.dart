import '../../../guard/domain/entities/checkin_entity.dart';
import '../../domain/repositories/resident_repository.dart';

class StreamVisitorHistoryUseCase {
  final ResidentRepository _repository;

  StreamVisitorHistoryUseCase(this._repository);

  Stream<List<CheckInEntity>> call(String flatNumber) {
    return _repository.streamVisitorHistory(flatNumber);
  }
}
