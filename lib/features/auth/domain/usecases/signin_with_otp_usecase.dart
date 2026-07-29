import '../../domain/entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SignInWithOtpUseCase {
  final AuthRepository _repository;

  SignInWithOtpUseCase(this._repository);

  Future<UserEntity> call({
    required String verificationId,
    required String smsCode,
  }) {
    return _repository.signInWithOtp(
      verificationId: verificationId,
      smsCode: smsCode,
    );
  }
}
