import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/services/mock_data_service.dart';
import '../../../../core/utils/constants.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final MockDataService _mockData = MockDataService();

  @override
  Stream<UserEntity?> get onAuthStateChanged {
    if (AppConstants.useMockData) {
      return _mockData.onAuthStateChanged;
    }
    
    return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      return await _getUserFromFirestore(firebaseUser.uid);
    });
  }

  @override
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onFailed,
  }) async {
    if (AppConstants.useMockData) {
      return await _mockData.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        onCodeSent: onCodeSent,
        onFailed: onFailed,
      );
    }

    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _firebaseAuth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          onFailed(e.message ?? 'Phone authentication verification failed');
        },
        codeSent: (String verificationId, int? resendToken) {
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      onFailed(e.toString());
    }
  }

  @override
  Future<UserEntity> signInWithOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    if (AppConstants.useMockData) {
      return await _mockData.signInWithOtp(
        verificationId: verificationId,
        smsCode: smsCode,
      );
    }

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      final credentials = await _firebaseAuth.signInWithCredential(credential);
      if (credentials.user == null) {
        throw Exception('Sign in failed: User is null');
      }
      final userEntity = await _getUserFromFirestore(credentials.user!.uid);
      if (userEntity == null) {
        final phoneNumber = credentials.user!.phoneNumber ?? '';
        final cleanPhone = phoneNumber.replaceAll(RegExp(r'\s+'), '');
        
        final UserModel stubUser;
        if (cleanPhone == '+919876543211') {
          stubUser = UserModel(
            uid: credentials.user!.uid,
            name: 'Guard Ramesh',
            role: 'GUARD',
            metadata: {'gateNumber': 'Gate 1'},
            fcmToken: '',
          );
        } else if (cleanPhone == '+919876543210') {
          stubUser = UserModel(
            uid: credentials.user!.uid,
            name: 'Amit Sharma',
            role: 'RESIDENT',
            metadata: {'flatNumber': 'A-402'},
            fcmToken: '',
          );
        } else {
          stubUser = UserModel(
            uid: credentials.user!.uid,
            name: 'New Resident',
            role: 'RESIDENT',
            metadata: {'flatNumber': 'A-101'},
            fcmToken: '',
          );
        }
        await _firestore.collection('users').doc(credentials.user!.uid).set(stubUser.toMap());
        return stubUser;
      }
      return userEntity;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    if (AppConstants.useMockData) {
      return await _mockData.logout();
    }
    await _firebaseAuth.signOut();
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    if (AppConstants.useMockData) {
      return await _mockData.getCurrentUser();
    }
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) return null;
    return await _getUserFromFirestore(firebaseUser.uid);
  }

  @override
  Future<void> updateFcmToken(String userId, String token) async {
    if (AppConstants.useMockData) {
      return await _mockData.updateFcmToken(userId, token);
    }
    await _firestore.collection('users').doc(userId).update({
      'fcmToken': token,
    });
  }

  Future<UserEntity?> _getUserFromFirestore(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!, uid);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
