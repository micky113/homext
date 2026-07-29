import '../../../guard/domain/entities/checkin_entity.dart';
import '../../domain/repositories/resident_repository.dart';

class StreamIncomingVisitorAlertsUseCase {
  final ResidentRepository _repository;

  StreamIncomingVisitorAlertsUseCase(this._repository);

  Stream<CheckInEntity> call(String flatNumber) {
    return _repository.streamIncomingAlerts(flatNumber);
  }
}
