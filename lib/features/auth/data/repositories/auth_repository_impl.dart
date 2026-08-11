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
  Future<UserEntity?> signInWithOtp({
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
            metadata: {'gateNumber': 'Gate 1', 'societyId': 'homext_heights', 'societyName': 'Homext Heights', 'phone': cleanPhone},
            fcmToken: '',
          );
          await _firestore.collection('guards').doc(credentials.user!.uid).set(stubUser.toMap());
          return stubUser;
        } else if (cleanPhone == '+919876543210') {
          stubUser = UserModel(
            uid: credentials.user!.uid,
            name: 'Amit Sharma',
            role: 'RESIDENT',
            metadata: {'flatNumber': 'A-402', 'societyId': 'homext_heights', 'societyName': 'Homext Heights', 'phone': cleanPhone},
            fcmToken: '',
          );
          await _firestore.collection('residents').doc(credentials.user!.uid).set(stubUser.toMap());
          return stubUser;
        } else {
          return null; // Signifies first-time login needing society verification
        }
      }
      return userEntity;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserEntity> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (AppConstants.useMockData) {
      return await _mockData.signInWithEmail(email: email, password: password);
    }

    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user == null) {
        throw Exception('Sign in failed: User is null');
      }
      final userEntity = await _getUserFromFirestore(credential.user!.uid);
      if (userEntity == null) {
        throw Exception('User profile not found in database');
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
    final results = await Future.wait([
      _firestore.collection('residents').doc(userId).get(),
      _firestore.collection('guards').doc(userId).get(),
      _firestore.collection('admins').doc(userId).get(),
    ]);
    if (results[0].exists) {
      await _firestore.collection('residents').doc(userId).update({'fcmToken': token});
    } else if (results[1].exists) {
      await _firestore.collection('guards').doc(userId).update({'fcmToken': token});
    } else if (results[2].exists) {
      await _firestore.collection('admins').doc(userId).update({'fcmToken': token});
    }
  }

  @override
  Future<void> updateProfile({
    required String userId,
    required String name,
    required String flatNumber,
  }) async {
    if (AppConstants.useMockData) {
      await _mockData.updateProfile(
        userId: userId,
        name: name,
        flatNumber: flatNumber,
      );
      return;
    }

    try {
      await _firestore.collection('residents').doc(userId).update({
        'name': name,
        'metadata.flatNumber': flatNumber,
      });
    } catch (e) {
      rethrow;
    }
  }

  @override
  Stream<List<UserEntity>> streamSocietyMembers(String societyId) {
    if (AppConstants.useMockData) {
      return _mockData.streamSocietyMembers(societyId).map((list) => list.map((m) => m as UserEntity).toList());
    }

    final controller = StreamController<List<UserEntity>>.broadcast();
    List<UserEntity> residents = [];
    List<UserEntity> guards = [];

    void emitMerged() {
      if (!controller.isClosed) {
        controller.add([...residents, ...guards]);
      }
    }

    final subResidents = _firestore
        .collection('residents')
        .where('metadata.societyId', isEqualTo: societyId)
        .snapshots()
        .listen((snapshot) {
      residents = snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data(), doc.id).copyWith(role: 'RESIDENT'))
          .toList();
      emitMerged();
    }, onError: (e) {
      if (!controller.isClosed) controller.addError(e);
    });

    final subGuards = _firestore
        .collection('guards')
        .where('metadata.societyId', isEqualTo: societyId)
        .snapshots()
        .listen((snapshot) {
      guards = snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data(), doc.id).copyWith(role: 'GUARD'))
          .toList();
      emitMerged();
    }, onError: (e) {
      if (!controller.isClosed) controller.addError(e);
    });

    controller.onCancel = () {
      subResidents.cancel();
      subGuards.cancel();
    };

    return controller.stream;
  }

  @override
  Future<void> preRegisterMember({
    required String name,
    required String phone,
    required String role,
    String? flatNumber,
    String? gateNumber,
    required String societyId,
    required String societyName,
  }) async {
    if (AppConstants.useMockData) {
      return await _mockData.preRegisterMember(
        name: name,
        phone: phone,
        role: role,
        flatNumber: flatNumber,
        gateNumber: gateNumber,
        societyId: societyId,
        societyName: societyName,
      );
    }

    try {
      var cleanPhone = phone.trim().replaceAll(RegExp(r'\s+'), '');
      if (!cleanPhone.startsWith('+')) {
        cleanPhone = '+91$cleanPhone';
      }
      
      await _firestore.collection('pre_registered_members').doc(cleanPhone).set({
        'name': name,
        'phone': cleanPhone,
        'role': role,
        if (flatNumber != null) 'flatNumber': flatNumber,
        if (gateNumber != null) 'gateNumber': gateNumber,
        'societyId': societyId,
        'societyName': societyName,
        'registeredAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserEntity?> verifyAndRegisterMember({
    required String userId,
    required String phoneNumber,
    required String societyName,
  }) async {
    if (AppConstants.useMockData) {
      return await _mockData.verifyAndRegisterMember(
        userId: userId,
        phoneNumber: phoneNumber,
        societyName: societyName,
      );
    }

    try {
      final cleanPhone = phoneNumber.replaceAll(RegExp(r'\s+'), '');
      final cleanSociety = societyName.trim().toLowerCase();

      final doc = await _firestore.collection('pre_registered_members').doc(cleanPhone).get();
      if (!doc.exists || doc.data() == null) {
        throw Exception('Your phone number is not pre-registered. Please contact your society admin.');
      }

      final data = doc.data()!;
      final registeredSociety = (data['societyName'] as String).toLowerCase();
      if (registeredSociety != cleanSociety) {
        throw Exception('Your phone number is not pre-registered for "$societyName". Please contact your society admin.');
      }

      final role = data['role'] ?? 'RESIDENT';
      final newUser = UserModel(
        uid: userId,
        name: data['name'] ?? (role == 'RESIDENT' ? 'Resident' : 'Guard'),
        role: role,
        metadata: {
          if (role == 'RESIDENT') 'flatNumber': data['flatNumber'] ?? '',
          if (role == 'GUARD') 'gateNumber': data['gateNumber'] ?? '',
          'societyId': data['societyId'] ?? '',
          'societyName': data['societyName'] ?? '',
          'phone': cleanPhone,
        },
        fcmToken: '',
      );

      if (role == 'RESIDENT') {
        await _firestore.collection('residents').doc(userId).set(newUser.toMap());
      } else {
        await _firestore.collection('guards').doc(userId).set(newUser.toMap());
      }
      return newUser;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> isPhoneNumberApproved(String phoneNumber) async {
    if (AppConstants.useMockData) {
      return await _mockData.isPhoneNumberApproved(phoneNumber);
    }

    try {
      final cleanPhone = phoneNumber.replaceAll(RegExp(r'\s+'), '');

      // 1. Check pre-registered members
      final preRegDoc = await _firestore.collection('pre_registered_members').doc(cleanPhone).get();
      if (preRegDoc.exists) return true;

      // 2. Check if they are already registered as a resident or guard
      final residentQuery = await _firestore
          .collection('residents')
          .where('metadata.phone', isEqualTo: cleanPhone)
          .limit(1)
          .get();
      if (residentQuery.docs.isNotEmpty) return true;

      final guardQuery = await _firestore
          .collection('guards')
          .where('metadata.phone', isEqualTo: cleanPhone)
          .limit(1)
          .get();
      if (guardQuery.docs.isNotEmpty) return true;

      return false;
    } catch (e) {
      return false;
    }
  }



  Future<UserEntity?> _getUserFromFirestore(String uid) async {
    try {
      final results = await Future.wait([
        _firestore.collection('residents').doc(uid).get(),
        _firestore.collection('guards').doc(uid).get(),
        _firestore.collection('admins').doc(uid).get(),
      ]);

      if (results[0].exists && results[0].data() != null) {
        return UserModel.fromMap(results[0].data()!, uid).copyWith(role: 'RESIDENT');
      }
      if (results[1].exists && results[1].data() != null) {
        return UserModel.fromMap(results[1].data()!, uid).copyWith(role: 'GUARD');
      }
      if (results[2].exists && results[2].data() != null) {
        return UserModel.fromMap(results[2].data()!, uid).copyWith(role: 'ADMIN');
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
