import '../entities/user_entity.dart';

abstract class AuthRepository {
  Stream<UserEntity?> get onAuthStateChanged;
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onFailed,
  });
  Future<UserEntity?> signInWithOtp({
    required String verificationId,
    required String smsCode,
  });
  Future<void> logout();
  Future<UserEntity?> getCurrentUser();
  Future<void> updateFcmToken(String userId, String token);
  Future<UserEntity> signInWithEmail({
    required String email,
    required String password,
  });
  Future<void> updateProfile({
    required String userId,
    required String name,
    required String flatNumber,
  });
  Stream<List<UserEntity>> streamSocietyMembers(String societyId);
  Future<void> preRegisterMember({
    required String name,
    required String phone,
    required String role,
    String? flatNumber,
    String? gateNumber,
    required String societyId,
    required String societyName,
  });
  Future<UserEntity?> verifyAndRegisterMember({
    required String userId,
    required String phoneNumber,
    required String societyName,
  });
  Future<bool> isPhoneNumberApproved(String phoneNumber);
}
