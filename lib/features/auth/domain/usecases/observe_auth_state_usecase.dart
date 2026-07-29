import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class ObserveAuthStateUseCase {
  final AuthRepository _repository;

  ObserveAuthStateUseCase(this._repository);

  Stream<UserEntity?> call() {
    return _repository.onAuthStateChanged;
  }
}
