import 'dart:async';
import '../../features/auth/data/models/user_model.dart';
import '../../features/guard/data/models/checkin_model.dart';
import '../../features/resident/data/models/invite_model.dart';

class MockDataService {
  // Singleton
  static final MockDataService _instance = MockDataService._internal();
  factory MockDataService() => _instance;
  MockDataService._internal() {
    // Populate default checkins
    _checkins.addAll([
      CheckInModel(
        id: 'chk-1',
        visitorName: 'Swiggy Delivery',
        purpose: 'Delivery',
        flatNumber: 'A-402',
        gateNumber: 'Gate 1',
        guardId: 'guard-1',
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        status: 'APPROVED',
      ),
      CheckInModel(
        id: 'chk-2',
        visitorName: 'Urban Company',
        purpose: 'Maintenance',
        flatNumber: 'B-101',
        gateNumber: 'Gate 1',
        guardId: 'guard-1',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        status: 'DENIED',
      ),
    ]);

    // Populate default invites
    _invites.addAll([
      InviteModel(
        id: 'inv-1',
        visitorName: 'Rohan Sharma',
        purpose: 'Friend Visit',
        inviteDate: DateTime.now().add(const Duration(days: 1)),
        inviteCode: 'MG-8892',
        flatNumber: 'A-402',
        hostName: 'Amit Sharma',
      ),
      InviteModel(
        id: 'inv-2',
        visitorName: 'Airtel Broadband Tech',
        purpose: 'Service',
        inviteDate: DateTime.now().add(const Duration(hours: 4)),
        inviteCode: 'MG-1243',
        flatNumber: 'A-402',
        hostName: 'Amit Sharma',
      ),
    ]);
  }

  // Active Simulated Users
  final List<UserModel> _users = [
    UserModel(
      uid: 'resident-1',
      name: 'Amit Sharma',
      role: 'RESIDENT',
      metadata: {'flatNumber': 'A-402'},
      fcmToken: 'mock-fcm-token-resident',
    ),
    UserModel(
      uid: 'guard-1',
      name: 'Guard Ramesh',
      role: 'GUARD',
      metadata: {'gateNumber': 'Gate 1'},
      fcmToken: 'mock-fcm-token-guard',
    ),
  ];

  // Simulated Database Stores
  final List<CheckInModel> _checkins = [];
  final List<InviteModel> _invites = [];

  // Stream Controllers for Real-Time Updates
  final StreamController<List<CheckInModel>> _checkinsStreamController = 
      StreamController<List<CheckInModel>>.broadcast();
  final StreamController<List<InviteModel>> _invitesStreamController = 
      StreamController<List<InviteModel>>.broadcast();
  
  // Custom Broadcast Channel for Incoming visitor alerts (SIMULATING FCM payloads)
  final StreamController<CheckInModel> _incomingAlertStreamController = 
      StreamController<CheckInModel>.broadcast();

  // Authentication State
  UserModel? _currentUser;
  final StreamController<UserModel?> _authStreamController = 
      StreamController<UserModel?>.broadcast();

  // Getters
  Stream<UserModel?> get onAuthStateChanged => _authStreamController.stream;
  Stream<List<CheckInModel>> get checkinsStream => _checkinsStreamController.stream;
  Stream<List<InviteModel>> get invitesStream => _invitesStreamController.stream;
  Stream<CheckInModel> get incomingAlertsStream => _incomingAlertStreamController.stream;

  UserModel? get currentUser => _currentUser;
  List<CheckInModel> get checkins => List.unmodifiable(_checkins);
  List<InviteModel> get invites => List.unmodifiable(_invites);

  // Temporary storage of active mock verification flows
  String? _mockVerificationId;
  String? _mockPhoneNumber;

  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onFailed,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'\s+'), '');
    _mockVerificationId = 'mock-ver-id-${DateTime.now().millisecondsSinceEpoch}';
    _mockPhoneNumber = cleanPhone;
    onCodeSent(_mockVerificationId!);
  }

  Future<UserModel> signInWithOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (_mockVerificationId != verificationId) {
      throw Exception('Invalid verification ID');
    }
    if (smsCode != '123456') {
      throw Exception('Incorrect OTP verification code. Enter 123456');
    }

    UserModel? user;
    if (_mockPhoneNumber == '+919876543211') {
      user = _users.firstWhere((u) => u.role == 'GUARD');
    } else if (_mockPhoneNumber == '+919876543210') {
      user = _users.firstWhere((u) => u.role == 'RESIDENT');
    } else {
      user = UserModel(
        uid: 'mock-user-${DateTime.now().millisecondsSinceEpoch}',
        name: 'New Resident',
        role: 'RESIDENT',
        metadata: {'flatNumber': 'C-302'},
        fcmToken: '',
      );
    }

    _currentUser = user;
    _authStreamController.add(_currentUser);
    return user;
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = null;
    _authStreamController.add(null);
  }

  Future<UserModel?> getCurrentUser() async {
    return _currentUser;
  }

  Future<void> updateFcmToken(String userId, String token) async {
    final index = _users.indexWhere((u) => u.uid == userId);
    if (index != -1) {
      _users[index] = _users[index].copyWith(fcmToken: token);
      if (_currentUser?.uid == userId) {
        _currentUser = _users[index];
      }
    }
  }

  // Guard Actions
  Future<CheckInModel> checkInVisitor({
    required String visitorName,
    required String purpose,
    required String flatNumber,
    required String gateNumber,
    required String guardId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final newCheckin = CheckInModel(
      id: 'chk-${DateTime.now().millisecondsSinceEpoch}',
      visitorName: visitorName,
      purpose: purpose,
      flatNumber: flatNumber,
      gateNumber: gateNumber,
      guardId: guardId,
      timestamp: DateTime.now(),
      status: 'PENDING',
    );

    _checkins.insert(0, newCheckin);
    _checkinsStreamController.add(List.from(_checkins));

    // Simulate sending FCM notification: Trigger Alert Event for Residents of this flat
    _incomingAlertStreamController.add(newCheckin);

    return newCheckin;
  }

  // Resident Actions
  Future<InviteModel> createInvite({
    required String visitorName,
    required String purpose,
    required DateTime inviteDate,
    required String flatNumber,
    required String hostName,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    final code = 'MG-${(1000 + (9000 * (DateTime.now().millisecond / 1000))).toInt()}';
    final newInvite = InviteModel(
      id: 'inv-${DateTime.now().millisecondsSinceEpoch}',
      visitorName: visitorName,
      purpose: purpose,
      inviteDate: inviteDate,
      inviteCode: code,
      flatNumber: flatNumber,
      hostName: hostName,
    );

    _invites.insert(0, newInvite);
    _invitesStreamController.add(List.from(_invites));
    return newInvite;
  }

  Future<CheckInModel> checkInPreApprovedVisitor({
    required String inviteCode,
    required String gateNumber,
    required String guardId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final index = _invites.indexWhere((invite) => invite.inviteCode.trim().toUpperCase() == inviteCode.trim().toUpperCase());
    if (index == -1) {
      throw Exception('Invalid or expired Invite Code. Please check the code.');
    }
    final invite = _invites[index];
    
    final newCheckin = CheckInModel(
      id: 'chk-${DateTime.now().millisecondsSinceEpoch}',
      visitorName: invite.visitorName,
      purpose: invite.purpose,
      flatNumber: invite.flatNumber.isNotEmpty ? invite.flatNumber : 'A-101',
      gateNumber: gateNumber,
      guardId: guardId,
      timestamp: DateTime.now(),
      status: 'APPROVED',
    );
    
    _checkins.insert(0, newCheckin);
    _checkinsStreamController.add(List.from(_checkins));
    
    _invites.removeAt(index);
    _invitesStreamController.add(List.from(_invites));
    
    return newCheckin;
  }

  Future<void> exitVisitor(String checkinId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final index = _checkins.indexWhere((c) => c.id == checkinId);
    if (index != -1) {
      final updated = _checkins[index].copyWith(status: 'EXITED');
      _checkins[index] = updated;
      _checkinsStreamController.add(List.from(_checkins));
    }
  }

  Future<void> respondToAlert(String checkinId, String status) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final index = _checkins.indexWhere((c) => c.id == checkinId);
    if (index != -1) {
      final updated = _checkins[index].copyWith(status: status);
      _checkins[index] = updated;
      _checkinsStreamController.add(List.from(_checkins));
    }
  }

  // Helper to trigger initial streams
  void initStreams() {
    _checkinsStreamController.add(List.from(_checkins));
    _invitesStreamController.add(List.from(_invites));
    _authStreamController.add(_currentUser);
  }
}
