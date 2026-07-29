import '../../domain/repositories/resident_repository.dart';

class RespondToVisitorAlertUseCase {
  final ResidentRepository _repository;

  RespondToVisitorAlertUseCase(this._repository);

  Future<void> call({
    required String checkinId,
    required String status,
  }) {
    return _repository.respondToAlert(
      checkinId: checkinId,
      status: status,
    );
  }
}
