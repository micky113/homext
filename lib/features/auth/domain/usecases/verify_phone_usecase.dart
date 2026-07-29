import '../repositories/auth_repository.dart';

class VerifyPhoneNumberUseCase {
  final AuthRepository _repository;

  VerifyPhoneNumberUseCase(this._repository);

  Future<void> call({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onFailed,
  }) {
    return _repository.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      onCodeSent: onCodeSent,
      onFailed: onFailed,
    );
  }
}
