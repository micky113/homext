import 'dart:async';
import 'dart:developer' as developer;
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
      metadata: {'flatNumber': 'A-402', 'societyId': 'homext_heights', 'societyName': 'Homext Heights', 'phone': '+919876543210'},
      fcmToken: 'mock-fcm-token-resident',
    ),
    UserModel(
      uid: 'guard-1',
      name: 'Guard Ramesh',
      role: 'GUARD',
      metadata: {'gateNumber': 'Gate 1', 'societyId': 'homext_heights', 'societyName': 'Homext Heights', 'phone': '+919876543211'},
      fcmToken: 'mock-fcm-token-guard',
    ),
    UserModel(
      uid: 'resident-2',
      name: 'John Doe',
      role: 'RESIDENT',
      metadata: {'flatNumber': 'B-305', 'societyId': 'sunrise_apartments', 'societyName': 'Sunrise Apartments', 'phone': '+919876543214'},
      fcmToken: 'mock-fcm-token-resident2',
    ),
    UserModel(
      uid: 'guard-2',
      name: 'Guard David',
      role: 'GUARD',
      metadata: {'gateNumber': 'Gate 1', 'societyId': 'sunrise_apartments', 'societyName': 'Sunrise Apartments', 'phone': '+919876543215'},
      fcmToken: 'mock-fcm-token-guard2',
    ),
    UserModel(
      uid: 'admin-1',
      name: 'Homext Heights Admin',
      role: 'ADMIN',
      metadata: {'societyId': 'homext_heights', 'societyName': 'Homext Heights'},
      fcmToken: 'mock-fcm-token-admin1',
    ),
    UserModel(
      uid: 'admin-2',
      name: 'Sunrise Apartments Admin',
      role: 'ADMIN',
      metadata: {'societyId': 'sunrise_apartments', 'societyName': 'Sunrise Apartments'},
      fcmToken: 'mock-fcm-token-admin2',
    ),
  ];

  // Pre-registered Members List (Residents & Guards)
  final List<Map<String, dynamic>> _preRegisteredMembers = [
    {
      'name': 'Sumit Verma',
      'phone': '+919876543212',
      'role': 'RESIDENT',
      'flatNumber': 'B-102',
      'societyId': 'homext_heights',
      'societyName': 'Homext Heights',
    },
    {
      'name': 'Jane Smith',
      'phone': '+919876543213',
      'role': 'RESIDENT',
      'flatNumber': 'C-404',
      'societyId': 'sunrise_apartments',
      'societyName': 'Sunrise Apartments',
    },
    {
      'name': 'Guard Suresh',
      'phone': '+919876543221',
      'role': 'GUARD',
      'gateNumber': 'Gate 2',
      'societyId': 'homext_heights',
      'societyName': 'Homext Heights',
    },
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

  Future<UserModel?> signInWithOtp({
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

    final cleanPhone = _mockPhoneNumber?.replaceAll(RegExp(r'\s+'), '') ?? '';
    final index = _users.indexWhere((u) => u.metadata['phone'] == cleanPhone);
    
    UserModel? user;
    if (index != -1) {
      user = _users[index];
    } else {
      user = null;
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

    developer.log("Simulating FCM Notification to Society Guards:");
    developer.log("Payload: { title: 'New Pre-Approved Invite', body: 'Flat $flatNumber ($hostName) pre-approved entry for $visitorName ($purpose)' }");
    
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

  Future<void> updateProfile({
    required String userId,
    required String name,
    required String flatNumber,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Update in _users list (if they exist there)
    final userIndex = _users.indexWhere((u) => u.uid == userId);
    if (userIndex != -1) {
      _users[userIndex] = _users[userIndex].copyWith(
        name: name,
        metadata: {
          ..._users[userIndex].metadata,
          'flatNumber': flatNumber,
        },
      );
    }
    
    // Update current authenticated user
    if (_currentUser != null && _currentUser!.uid == userId) {
      _currentUser = _currentUser!.copyWith(
        name: name,
        metadata: {
          ..._currentUser!.metadata,
          'flatNumber': flatNumber,
        },
      );
      _authStreamController.add(_currentUser);
    }
  }

  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final cleanEmail = email.trim().toLowerCase();
    
    if (cleanEmail == 'admin@homext.com' && password == 'password123') {
      final user = _users.firstWhere((u) => u.uid == 'admin-1');
      _currentUser = user;
      _authStreamController.add(_currentUser);
      return user;
    } else if (cleanEmail == 'admin@sunrise.com' && password == 'password123') {
      final user = _users.firstWhere((u) => u.uid == 'admin-2');
      _currentUser = user;
      _authStreamController.add(_currentUser);
      return user;
    } else {
      throw Exception('Invalid email or password. Use admin@homext.com / password123');
    }
  }

  Stream<List<UserModel>> streamSocietyMembers(String societyId) {
    final controller = StreamController<List<UserModel>>.broadcast();
    
    // Push initial
    final initial = _users.where((u) => u.metadata['societyId'] == societyId).toList();
    controller.add(initial);
    
    // Listen to changes
    final sub = onAuthStateChanged.listen((_) {
      final updated = _users.where((u) => u.metadata['societyId'] == societyId).toList();
      controller.add(updated);
    });
    
    controller.onCancel = () {
      sub.cancel();
    };
    
    return controller.stream;
  }

  Future<void> preRegisterMember({
    required String name,
    required String phone,
    required String role,
    String? flatNumber,
    String? gateNumber,
    required String societyId,
    required String societyName,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    var cleanPhone = phone.trim().replaceAll(RegExp(r'\s+'), '');
    if (!cleanPhone.startsWith('+')) {
      cleanPhone = '+91$cleanPhone';
    }
    
    _preRegisteredMembers.removeWhere((item) => item['phone'] == cleanPhone);
    
    _preRegisteredMembers.add({
      'name': name,
      'phone': cleanPhone,
      'role': role,
      'flatNumber': flatNumber,
      'gateNumber': gateNumber,
      'societyId': societyId,
      'societyName': societyName,
    });
  }

  Future<UserModel?> verifyAndRegisterMember({
    required String userId,
    required String phoneNumber,
    required String societyName,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'\s+'), '');
    final cleanSociety = societyName.trim().toLowerCase();

    final matchIndex = _preRegisteredMembers.indexWhere((item) =>
        item['phone'] == cleanPhone &&
        (item['societyName'] as String).toLowerCase() == cleanSociety);

    if (matchIndex == -1) {
      throw Exception('Your phone number is not pre-registered for "$societyName". Please contact your society admin.');
    }

    final match = _preRegisteredMembers[matchIndex];
    final role = match['role'] ?? 'RESIDENT';

    final newUser = UserModel(
      uid: userId,
      name: match['name'],
      role: role,
      metadata: {
        if (role == 'RESIDENT') 'flatNumber': match['flatNumber'] ?? '',
        if (role == 'GUARD') 'gateNumber': match['gateNumber'] ?? '',
        'societyId': match['societyId'],
        'societyName': match['societyName'],
        'phone': cleanPhone,
      },
      fcmToken: '',
    );

    _users.add(newUser);
    
    _currentUser = newUser;
    _authStreamController.add(_currentUser);
    
    return newUser;
  }

  Future<bool> isPhoneNumberApproved(String phoneNumber) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'\s+'), '');
    
    // Check registered users
    final existsInUsers = _users.any((u) => u.metadata['phone'] == cleanPhone);
    if (existsInUsers) return true;

    // Check pre-registered members
    final existsInPreReg = _preRegisteredMembers.any((m) => m['phone'] == cleanPhone);
    return existsInPreReg;
  }

  // Helper to trigger initial streams
  void initStreams() {
    _checkinsStreamController.add(List.from(_checkins));
    _invitesStreamController.add(List.from(_invites));
    _authStreamController.add(_currentUser);
  }
}
