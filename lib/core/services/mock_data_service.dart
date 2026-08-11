import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import '../../features/auth/data/models/user_model.dart';
import '../../features/guard/data/models/checkin_model.dart';
import '../../features/resident/data/models/invite_model.dart';
import '../../features/resident/data/models/notice_model.dart';

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

    _notices.addAll([
      NoticeModel(
        id: 'notice-1',
        title: 'Annual General Meeting (AGM)',
        content: 'Dear Residents, our Annual General Meeting is scheduled for this Sunday at 10:00 AM in the clubhouse. Please make sure to attend as we will discuss the upcoming painting project.',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        societyId: 'homext_heights',
        postedBy: 'Homext Heights Admin',
      ),
      NoticeModel(
        id: 'notice-2',
        title: 'Water Supply Interruption',
        content: 'Please note that there will be a temporary water supply interruption this Wednesday from 2:00 PM to 5:00 PM due to regular overhead tank cleaning. Kindly store sufficient water.',
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
        societyId: 'homext_heights',
        postedBy: 'Homext Heights Admin',
      ),
      NoticeModel(
        id: 'notice-3',
        title: 'Independence Day Celebration',
        content: 'We invite all residents to join the flag hoisting ceremony at 8:30 AM in the main park, followed by cultural programs and high tea.',
        timestamp: DateTime.now().subtract(const Duration(days: 5)),
        societyId: 'homext_heights',
        postedBy: 'Homext Heights Admin',
      ),
      NoticeModel(
        id: 'notice-4',
        title: 'Power Maintenance Shutdown',
        content: 'There will be a power shutdown on Saturday from 10:00 AM to 1:00 PM for transformer servicing.',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        societyId: 'sunrise_apartments',
        postedBy: 'Sunrise Apartments Admin',
      )
    ]);
  }

  // Active Simulated Users
  final List<UserModel> _users = [
    UserModel(
      uid: 'resident-1',
      name: 'Amit Sharma',
      role: 'RESIDENT',
      metadata: {
        'flatNumber': 'A-402',
        'societyId': 'homext_heights',
        'societyName': 'Homext Heights',
        'phone': '+919876543210',
        'pendingDues': '2000',
        'maintenancePaid': 'false',
        'charges': <Map<String, String>>[],
        'paymentStatus': 'unpaid',
        'paymentRemarks': '',
      },
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
      metadata: {
        'flatNumber': 'B-305',
        'societyId': 'sunrise_apartments',
        'societyName': 'Sunrise Apartments',
        'phone': '+919876543214',
        'pendingDues': '2500',
        'maintenancePaid': 'false',
        'charges': <Map<String, String>>[],
        'paymentStatus': 'unpaid',
        'paymentRemarks': '',
      },
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
  final List<NoticeModel> _notices = [];
  final Map<String, String> _societyMaintenance = {'homext_heights': '2000', 'sunrise_apartments': '2500'};
  final StreamController<Map<String, String>> _societyMaintenanceStreamController = 
      StreamController<Map<String, String>>.broadcast();

  // Stream Controllers for Real-Time Updates
  final StreamController<List<CheckInModel>> _checkinsStreamController = 
      StreamController<List<CheckInModel>>.broadcast();
  final StreamController<List<InviteModel>> _invitesStreamController = 
      StreamController<List<InviteModel>>.broadcast();
  final StreamController<List<NoticeModel>> _noticesStreamController = 
      StreamController<List<NoticeModel>>.broadcast();
  
  // Custom Broadcast Channel for Incoming visitor alerts (SIMULATING FCM payloads)
  final StreamController<CheckInModel> _incomingAlertStreamController = 
      StreamController<CheckInModel>.broadcast();

  // Authentication State
  UserModel? _currentUser;
  final StreamController<UserModel?> _authStreamController = 
      StreamController<UserModel?>.broadcast();
  final StreamController<void> _usersUpdateController = 
      StreamController<void>.broadcast();

  // Getters
  Stream<UserModel?> get onAuthStateChanged => _authStreamController.stream;
  Stream<List<CheckInModel>> get checkinsStream => _checkinsStreamController.stream;
  Stream<List<InviteModel>> get invitesStream => _invitesStreamController.stream;
  Stream<CheckInModel> get incomingAlertsStream => _incomingAlertStreamController.stream;
  Stream<List<NoticeModel>> get noticesStream => _noticesStreamController.stream;

  UserModel? get currentUser => _currentUser;
  List<CheckInModel> get checkins => List.unmodifiable(_checkins);
  List<InviteModel> get invites => List.unmodifiable(_invites);
  List<NoticeModel> get notices => List.unmodifiable(_notices);

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
    debugPrint("DEBUG: streamSocietyMembers called for societyId: $societyId");
    final controller = StreamController<List<UserModel>>.broadcast();
    
    // Push initial
    final initial = _users.where((u) => u.metadata['societyId'] == societyId).toList();
    debugPrint("DEBUG: streamSocietyMembers initial count: ${initial.length} for $societyId");
    controller.add(initial);
    
    // Listen to changes
    final sub = onAuthStateChanged.listen((user) {
      debugPrint("DEBUG: streamSocietyMembers onAuthStateChanged fired. Current user: ${user?.name}");
      final updated = _users.where((u) => u.metadata['societyId'] == societyId).toList();
      debugPrint("DEBUG: streamSocietyMembers emitting updated list. Count: ${updated.length}");
      controller.add(updated);
    });

    final sub2 = _usersUpdateController.stream.listen((_) {
      debugPrint("DEBUG: streamSocietyMembers _usersUpdateController fired.");
      final updated = _users.where((u) => u.metadata['societyId'] == societyId).toList();
      debugPrint("DEBUG: streamSocietyMembers emitting updated list from database trigger. Count: ${updated.length}");
      for (final u in updated) {
        debugPrint("   -> ${u.name}: pendingDues = ${u.metadata['pendingDues']}");
      }
      controller.add(updated);
    });
    
    controller.onCancel = () {
      debugPrint("DEBUG: streamSocietyMembers stream cancelled for $societyId");
      sub.cancel();
      sub2.cancel();
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

  Future<void> postNotice({
    required String societyId,
    required String title,
    required String content,
    required String postedBy,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final newNotice = NoticeModel(
      id: 'notice-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      content: content,
      timestamp: DateTime.now(),
      societyId: societyId,
      postedBy: postedBy,
    );
    _notices.insert(0, newNotice);
    _noticesStreamController.add(List.from(_notices));
  }

  Future<void> payDues(String userId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final index = _users.indexWhere((u) => u.uid == userId);
    if (index != -1) {
      final user = _users[index];
      final Map<String, dynamic> updatedMetadata = Map.from(user.metadata);
      updatedMetadata['maintenancePaid'] = 'true';
      updatedMetadata['charges'] = <Map<String, String>>[];
      updatedMetadata['pendingDues'] = '0';
      updatedMetadata['paymentStatus'] = 'paid';
      updatedMetadata['paymentRemarks'] = '';
      _users[index] = user.copyWith(metadata: updatedMetadata);
      
      if (_currentUser?.uid == userId) {
        _currentUser = _users[index];
        _authStreamController.add(_currentUser);
      }
      _usersUpdateController.add(null);
    }
  }

  Future<void> rejectPayment(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _users.indexWhere((u) => u.uid == userId);
    if (index != -1) {
      final user = _users[index];
      final Map<String, dynamic> updatedMetadata = Map.from(user.metadata);
      updatedMetadata['paymentStatus'] = 'unpaid';
      updatedMetadata['paymentRemarks'] = '';
      _users[index] = user.copyWith(metadata: updatedMetadata);

      if (_currentUser?.uid == userId) {
        _currentUser = _users[index];
        _authStreamController.add(_currentUser);
      }
      _usersUpdateController.add(null);
    }
  }

  Future<void> submitPaymentVerification(String userId, String remarks) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _users.indexWhere((u) => u.uid == userId);
    if (index != -1) {
      final user = _users[index];
      final Map<String, dynamic> updatedMetadata = Map.from(user.metadata);
      updatedMetadata['paymentStatus'] = 'pending_confirmation';
      updatedMetadata['paymentRemarks'] = remarks;
      _users[index] = user.copyWith(metadata: updatedMetadata);

      if (_currentUser?.uid == userId) {
        _currentUser = _users[index];
        _authStreamController.add(_currentUser);
      }
      _usersUpdateController.add(null);
    }
  }

  Stream<String> streamMonthlyMaintenance(String societyId) {
    final controller = StreamController<String>.broadcast();
    controller.add(_societyMaintenance[societyId] ?? '2500');
    
    final sub = _societyMaintenanceStreamController.stream.listen((data) {
      controller.add(data[societyId] ?? '2500');
    });
    
    controller.onCancel = () => sub.cancel();
    return controller.stream;
  }

  Future<void> updateMonthlyMaintenance(String societyId, String amount) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _societyMaintenance[societyId] = amount;
    _societyMaintenanceStreamController.add(Map.from(_societyMaintenance));
    
    for (int i = 0; i < _users.length; i++) {
      final user = _users[i];
      if (user.role == 'RESIDENT' && user.metadata['societyId'] == societyId) {
        final Map<String, dynamic> updatedMetadata = Map.from(user.metadata);
        final paid = updatedMetadata['maintenancePaid'] == 'true';
        final chargesList = updatedMetadata['charges'] as List? ?? [];
        double customSum = 0;
        for (final c in chargesList) {
          customSum += double.tryParse(c['amount']?.toString() ?? '0') ?? 0;
        }
        final total = (paid ? 0.0 : (double.tryParse(amount) ?? 0.0)) + customSum;
        updatedMetadata['pendingDues'] = total.toStringAsFixed(0);
        _users[i] = user.copyWith(metadata: updatedMetadata);
      }
    }
    
    final current = _currentUser;
    if (current != null) {
      final match = _users.firstWhere((u) => u.uid == current.uid, orElse: () => current);
      _currentUser = match;
      _authStreamController.add(_currentUser);
    }
    _usersUpdateController.add(null);
  }

  Future<void> addCustomCharge(String userId, String title, String amount) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _users.indexWhere((u) => u.uid == userId);
    if (index != -1) {
      final user = _users[index];
      final Map<String, dynamic> updatedMetadata = Map.from(user.metadata);
      
      final List<Map<String, String>> charges = List.from(
        (updatedMetadata['charges'] as List?)?.map((item) => Map<String, String>.from(item as Map)) ?? []
      );
      
      charges.add({
        'id': 'charge-${DateTime.now().millisecondsSinceEpoch}',
        'title': title,
        'amount': amount,
      });
      updatedMetadata['charges'] = charges;
      updatedMetadata['paymentStatus'] = 'unpaid';
      updatedMetadata['paymentRemarks'] = '';
      
      final societyId = updatedMetadata['societyId'] ?? '';
      final fixedFee = double.tryParse(_societyMaintenance[societyId] ?? '2500') ?? 2500.0;
      final paid = updatedMetadata['maintenancePaid'] == 'true';
      
      double customSum = 0;
      for (final c in charges) {
        customSum += double.tryParse(c['amount']?.toString() ?? '0') ?? 0;
      }
      final total = (paid ? 0.0 : fixedFee) + customSum;
      updatedMetadata['pendingDues'] = total.toStringAsFixed(0);
      
      _users[index] = user.copyWith(metadata: updatedMetadata);
      
      if (_currentUser?.uid == userId) {
        _currentUser = _users[index];
        _authStreamController.add(_currentUser);
      }
      _usersUpdateController.add(null);
    }
  }

  Future<void> generateMonthlyBills(String societyId) async {
    debugPrint("DEBUG: generateMonthlyBills called for societyId: $societyId");
    await Future.delayed(const Duration(milliseconds: 400));
    final fixedFee = double.tryParse(_societyMaintenance[societyId] ?? '2500') ?? 2500.0;
    debugPrint("DEBUG: generateMonthlyBills fixedFee for $societyId is $fixedFee");
    
    int matchCount = 0;
    for (int i = 0; i < _users.length; i++) {
      final user = _users[i];
      if (user.role == 'RESIDENT' && user.metadata['societyId'] == societyId) {
        matchCount++;
        final Map<String, dynamic> updatedMetadata = Map.from(user.metadata);
        
        final double currentPending = double.tryParse(updatedMetadata['pendingDues']?.toString() ?? '0') ?? 0.0;
        final double newPending = currentPending + fixedFee;
        
        debugPrint("DEBUG: Resident ${user.name} dues update: $currentPending -> $newPending");
        
        updatedMetadata['pendingDues'] = newPending.toStringAsFixed(0);
        updatedMetadata['maintenancePaid'] = 'false';
        updatedMetadata['paymentStatus'] = 'unpaid';
        updatedMetadata['paymentRemarks'] = '';
        
        _users[i] = user.copyWith(metadata: updatedMetadata);
      }
    }
    debugPrint("DEBUG: generateMonthlyBills processed $matchCount residents.");
    
    final current = _currentUser;
    if (current != null) {
      final match = _users.firstWhere((u) => u.uid == current.uid, orElse: () => current);
      _currentUser = match;
      debugPrint("DEBUG: generateMonthlyBills adding current user ${_currentUser?.name} to auth stream.");
      _authStreamController.add(_currentUser);
    }
    debugPrint("DEBUG: generateMonthlyBills triggering database updates stream.");
    _usersUpdateController.add(null);
  }

  Future<void> billSpecialCharge(String societyId, String title, String amount) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final fee = double.tryParse(amount) ?? 0.0;
    
    for (int i = 0; i < _users.length; i++) {
      final user = _users[i];
      if (user.role == 'RESIDENT' && user.metadata['societyId'] == societyId) {
        final Map<String, dynamic> updatedMetadata = Map.from(user.metadata);
        
        final List<Map<String, String>> charges = List.from(
          (updatedMetadata['charges'] as List?)?.map((item) => Map<String, String>.from(item as Map)) ?? []
        );
        
        final charge = {
          'id': 'charge-${DateTime.now().millisecondsSinceEpoch}',
          'title': title,
          'amount': amount,
        };
        
        charges.add(charge);
        updatedMetadata['charges'] = charges;
        
        final double currentPending = double.tryParse(updatedMetadata['pendingDues']?.toString() ?? '0') ?? 0.0;
        final double newPending = currentPending + fee;
        
        updatedMetadata['pendingDues'] = newPending.toStringAsFixed(0);
        updatedMetadata['paymentStatus'] = 'unpaid';
        updatedMetadata['paymentRemarks'] = '';
        
        _users[i] = user.copyWith(metadata: updatedMetadata);
      }
    }
    
    final current = _currentUser;
    if (current != null) {
      final match = _users.firstWhere((u) => u.uid == current.uid, orElse: () => current);
      _currentUser = match;
      _authStreamController.add(_currentUser);
    }
    _usersUpdateController.add(null);
  }

  // Helper to trigger initial streams
  void initStreams() {
    _checkinsStreamController.add(List.from(_checkins));
    _invitesStreamController.add(List.from(_invites));
    _noticesStreamController.add(List.from(_notices));
    _societyMaintenanceStreamController.add(Map.from(_societyMaintenance));
    _authStreamController.add(_currentUser);
  }
}
