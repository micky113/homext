import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import '../../data/repositories/resident_repository_impl.dart';
import '../../../guard/domain/entities/checkin_entity.dart';
import '../../domain/entities/invite_entity.dart';
import '../../domain/entities/notice_entity.dart';
import '../../domain/usecases/create_invite_usecase.dart';
import '../../domain/usecases/stream_invites_usecase.dart';
import '../../domain/usecases/respond_to_visitor_alert_usecase.dart';
import '../../domain/usecases/stream_incoming_visitor_alerts_usecase.dart';
import '../../domain/usecases/stream_visitor_history_usecase.dart';

class ResidentProvider extends ChangeNotifier {
  final CreateInviteUseCase _createInviteUseCase;
  final StreamInvitesUseCase _streamInvitesUseCase;
  final RespondToVisitorAlertUseCase _respondToVisitorAlertUseCase;
  final StreamIncomingVisitorAlertsUseCase _streamIncomingVisitorAlertsUseCase;
  final StreamVisitorHistoryUseCase _streamVisitorHistoryUseCase;

  List<InviteEntity> _invites = [];
  List<CheckInEntity> _history = [];
  List<NoticeEntity> _notices = [];
  String _monthlyMaintenance = '2500';
  CheckInEntity? _activeAlert; 
  bool _isLoading = false;
  String? _errorMessage;

  StreamSubscription<List<InviteEntity>>? _invitesSubscription;
  StreamSubscription<CheckInEntity>? _alertsSubscription;
  StreamSubscription<List<CheckInEntity>>? _historySubscription;
  StreamSubscription<List<NoticeEntity>>? _noticesSubscription;
  StreamSubscription<String>? _maintenanceSubscription;

  ResidentProvider()
      : _createInviteUseCase = CreateInviteUseCase(ResidentRepositoryImpl()),
        _streamInvitesUseCase = StreamInvitesUseCase(ResidentRepositoryImpl()),
        _respondToVisitorAlertUseCase = RespondToVisitorAlertUseCase(ResidentRepositoryImpl()),
        _streamIncomingVisitorAlertsUseCase = StreamIncomingVisitorAlertsUseCase(ResidentRepositoryImpl()),
        _streamVisitorHistoryUseCase = StreamVisitorHistoryUseCase(ResidentRepositoryImpl());

  List<InviteEntity> get invites => _invites;
  List<CheckInEntity> get history => _history;
  List<NoticeEntity> get notices => _notices;
  String get monthlyMaintenance => _monthlyMaintenance;
  CheckInEntity? get activeAlert => _activeAlert;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Initialize data queries once resident user profile is ready
  void initialize(String userId, String flatNumber, String societyId) {
    _stopListening();
    _isLoading = true;

    // 1. Stream pre-approved invites
    _invitesSubscription = _streamInvitesUseCase.call(userId).listen(
      (data) {
        _invites = data;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (err) {
        _errorMessage = err.toString();
        _isLoading = false;
        notifyListeners();
      },
    );

    // 2. Stream incoming visitor requests matching this flat number
    _alertsSubscription = _streamIncomingVisitorAlertsUseCase.call(flatNumber).listen(
      (alert) {
        if (alert.status == 'PENDING') {
          _activeAlert = alert;
          notifyListeners();
        }
      },
      onError: (err) {
        developer.log("Error streaming alerts: $err");
      },
    );

    // 3. Stream visitor history matching this flat number
    _historySubscription = _streamVisitorHistoryUseCase.call(flatNumber).listen(
      (data) {
        _history = data;
        notifyListeners();
      },
      onError: (err) {
        developer.log("Error streaming visitor history: $err");
      },
    );

    // 4. Stream society notices matching this societyId
    _noticesSubscription = ResidentRepositoryImpl().streamNotices(societyId).listen(
      (data) {
        _notices = data;
        notifyListeners();
      },
      onError: (err) {
        developer.log("Error streaming notices: $err");
      },
    );

    // 5. Stream society monthly maintenance
    _maintenanceSubscription = ResidentRepositoryImpl().streamMonthlyMaintenance(societyId).listen(
      (amount) {
        _monthlyMaintenance = amount;
        notifyListeners();
      },
      onError: (err) {
        developer.log("Error streaming monthly maintenance: $err");
      },
    );
  }

  void clearActiveAlert() {
    _activeAlert = null;
    notifyListeners();
  }

  Future<bool> createInvite({
    required String userId,
    required String visitorName,
    required String purpose,
    required DateTime inviteDate,
    required String flatNumber,
    required String hostName,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _createInviteUseCase.call(
        userId: userId,
        visitorName: visitorName,
        purpose: purpose,
        inviteDate: inviteDate,
        flatNumber: flatNumber,
        hostName: hostName,
      );
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

  Future<void> respondToAlert(String checkinId, String status) async {
    try {
      await _respondToVisitorAlertUseCase.call(
        checkinId: checkinId,
        status: status,
      );
      if (_activeAlert?.id == checkinId) {
        _activeAlert = null;
      }
      notifyListeners();
    } catch (e) {
      developer.log("Error responding to alert: $e");
    }
  }

  Future<void> payDues(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await ResidentRepositoryImpl().payDues(userId: userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      developer.log("Error paying dues: $e");
      notifyListeners();
    }
  }

  Future<void> rejectPayment(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await ResidentRepositoryImpl().rejectPayment(userId: userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      developer.log("Error rejecting payment: $e");
      notifyListeners();
    }
  }

  Future<void> submitPaymentVerification({required String userId, required String remarks}) async {
    _isLoading = true;
    notifyListeners();
    try {
      await ResidentRepositoryImpl().submitPaymentVerification(userId: userId, remarks: remarks);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      developer.log("Error submitting payment verification: $e");
      notifyListeners();
    }
  }

  void _stopListening() {
    _invitesSubscription?.cancel();
    _alertsSubscription?.cancel();
    _historySubscription?.cancel();
    _noticesSubscription?.cancel();
    _maintenanceSubscription?.cancel();
    _invites = [];
    _history = [];
    _notices = [];
    _monthlyMaintenance = '2500';
    _activeAlert = null;
  }

  @override
  void dispose() {
    _stopListening();
    super.dispose();
  }
}
