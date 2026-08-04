import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/models/user_model.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/verify_phone_usecase.dart';
import '../../domain/usecases/signin_with_otp_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/observe_auth_state_usecase.dart';

class AuthProvider extends ChangeNotifier {
  final ObserveAuthStateUseCase _observeAuthState;
  final VerifyPhoneNumberUseCase _verifyPhoneUseCase;
  final SignInWithOtpUseCase _signInWithOtpUseCase;
  final LogoutUseCase _logoutUseCase;
  final AuthRepositoryImpl _authRepository;

  UserEntity? _currentUser;
  bool _isLoading = true;
  String? _errorMessage;
  StreamSubscription<UserEntity?>? _authSubscription;

  // Phone Auth State
  bool _codeSent = false;
  String? _verificationId;
  String? _phoneNumber;
  bool _isEmailMode = false;
  
  bool _needsSocietyVerification = false;
  String? _tempUserId;
  String? _tempPhoneNumber;

  AuthProvider() 
      : _authRepository = AuthRepositoryImpl(),
        _observeAuthState = ObserveAuthStateUseCase(AuthRepositoryImpl()),
        _verifyPhoneUseCase = VerifyPhoneNumberUseCase(AuthRepositoryImpl()),
        _signInWithOtpUseCase = SignInWithOtpUseCase(AuthRepositoryImpl()),
        _logoutUseCase = LogoutUseCase(AuthRepositoryImpl()) {
    _init();
  }

  UserEntity? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  bool get codeSent => _codeSent;
  String? get verificationId => _verificationId;
  String? get phoneNumber => _phoneNumber;
  bool get isEmailMode => _isEmailMode;
  bool get needsSocietyVerification => _needsSocietyVerification;
  String? get tempPhoneNumber => _tempPhoneNumber;

  void _init() {
    _authSubscription = _observeAuthState.call().listen((user) {
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
    }, onError: (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    });
  }

  // Phase 1: Send OTP to Phone Number
  Future<bool> sendOtp(String phone) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final cleanPhone = phone.trim().replaceAll(RegExp(r'\s+'), '');
      
      final isApproved = await _authRepository.isPhoneNumberApproved(cleanPhone);
      if (!isApproved) {
        _errorMessage = 'Your phone number is not approved by any society admin. Please contact your admin.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final completer = Completer<bool>();
      await _verifyPhoneUseCase.call(
        phoneNumber: cleanPhone,
        onCodeSent: (verId) {
          _verificationId = verId;
          _phoneNumber = cleanPhone;
          _codeSent = true;
          _isLoading = false;
          notifyListeners();
          completer.complete(true);
        },
        onFailed: (error) {
          _errorMessage = error.replaceAll(RegExp(r'\[.*\]'), '').trim();
          _isLoading = false;
          notifyListeners();
          completer.complete(false);
        },
      );
      return completer.future;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Phase 2: Verify OTP
  Future<bool> verifyOtp(String smsCode) async {
    if (_verificationId == null) {
      _errorMessage = 'No verification session found. Request OTP again.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _signInWithOtpUseCase.call(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );
      
      if (user == null) {
        _needsSocietyVerification = true;
        
        final fbUser = FirebaseAuth.instance.currentUser;
        _tempUserId = fbUser?.uid ?? 'mock-temp-uid-${DateTime.now().millisecondsSinceEpoch}';
        _tempPhoneNumber = fbUser?.phoneNumber ?? _phoneNumber;
        
        _currentUser = null;
        _isLoading = false;
        resetPhoneAuthState();
        notifyListeners();
        return true;
      } else {
        _currentUser = user;
        _needsSocietyVerification = false;
        _isLoading = false;
        resetPhoneAuthState();
        notifyListeners();
        return true;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll(RegExp(r'\[.*\]'), '').trim();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void resetPhoneAuthState() {
    _codeSent = false;
    _verificationId = null;
    _phoneNumber = null;
    notifyListeners();
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    await _logoutUseCase.call();
    _currentUser = null;
    resetPhoneAuthState();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateFcmToken(String token) async {
    if (_currentUser != null) {
      await _authRepository.updateFcmToken(_currentUser!.uid, token);
      final updatedUser = await _authRepository.getCurrentUser();
      if (updatedUser != null) {
        _currentUser = updatedUser;
        notifyListeners();
      }
    }
  }

  Future<bool> updateProfile({required String name, required String flatNumber}) async {
    if (_currentUser == null) return false;
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      await _authRepository.updateProfile(
        userId: _currentUser!.uid,
        name: name,
        flatNumber: flatNumber,
      );
      
      final updatedUser = await _authRepository.getCurrentUser();
      if (updatedUser != null) {
        _currentUser = updatedUser;
      } else {
        _currentUser = UserModel(
          uid: _currentUser!.uid,
          name: name,
          role: _currentUser!.role,
          metadata: {'flatNumber': flatNumber},
          fcmToken: _currentUser!.fcmToken,
        );
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void toggleEmailMode() {
    _isEmailMode = !_isEmailMode;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> loginWithEmail(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      _currentUser = await _authRepository.signInWithEmail(
        email: email,
        password: password,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll(RegExp(r'\[.*\]'), '').trim();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void resetSocietyVerificationState() {
    _needsSocietyVerification = false;
    _tempUserId = null;
    _tempPhoneNumber = null;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> verifyAndRegisterMember(String societyName) async {
    if (_tempUserId == null || _tempPhoneNumber == null) {
      _errorMessage = 'No active verification session. Please sign in again.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authRepository.verifyAndRegisterMember(
        userId: _tempUserId!,
        phoneNumber: _tempPhoneNumber!,
        societyName: societyName,
      );
      
      _currentUser = user;
      _needsSocietyVerification = false;
      _tempUserId = null;
      _tempPhoneNumber = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll(RegExp(r'\[.*\]'), '').trim();
      _isLoading = false;
      
      // Auto signout from firebase so auth state doesn't get stuck
      _authRepository.logout();
      
      notifyListeners();
      return false;
    }
  }

  Future<bool> preRegisterMember({
    required String name,
    required String phone,
    required String role,
    String? flatNumber,
    String? gateNumber,
    required String societyId,
    required String societyName,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.preRegisterMember(
        name: name,
        phone: phone,
        role: role,
        flatNumber: flatNumber,
        gateNumber: gateNumber,
        societyId: societyId,
        societyName: societyName,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll(RegExp(r'\[.*\]'), '').trim();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }



  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
