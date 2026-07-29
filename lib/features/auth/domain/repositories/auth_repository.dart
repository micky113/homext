import '../entities/user_entity.dart';

abstract class AuthRepository {
  Stream<UserEntity?> get onAuthStateChanged;
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onFailed,
  });
  Future<UserEntity> signInWithOtp({
    required String verificationId,
    required String smsCode,
  });
  Future<void> logout();
  Future<UserEntity?> getCurrentUser();
  Future<void> updateFcmToken(String userId, String token);
}
