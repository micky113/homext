import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/repositories/auth_repository_impl.dart';
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

    final completer = Completer<bool>();

    try {
      await _verifyPhoneUseCase.call(
        phoneNumber: phone,
        onCodeSent: (verId) {
          _verificationId = verId;
          _phoneNumber = phone;
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
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      completer.complete(false);
    }

    return completer.future;
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
      _currentUser = await _signInWithOtpUseCase.call(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );
      _isLoading = false;
      // Clear phone auth state on success
      resetPhoneAuthState();
      notifyListeners();
      return true;
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

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
