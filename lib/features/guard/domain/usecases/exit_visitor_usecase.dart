import '../../domain/repositories/guard_repository.dart';

class ExitVisitorUseCase {
  final GuardRepository _repository;

  ExitVisitorUseCase(this._repository);

  Future<void> call(String checkinId) {
    return _repository.exitVisitor(checkinId);
  }
}
