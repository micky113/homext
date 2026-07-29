import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import '../../data/repositories/resident_repository_impl.dart';
import '../../../guard/domain/entities/checkin_entity.dart';
import '../../domain/entities/invite_entity.dart';
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
  CheckInEntity? _activeAlert; // Currently pending checkin alert
  bool _isLoading = false;
  String? _errorMessage;

  StreamSubscription<List<InviteEntity>>? _invitesSubscription;
  StreamSubscription<CheckInEntity>? _alertsSubscription;
  StreamSubscription<List<CheckInEntity>>? _historySubscription;

  ResidentProvider()
      : _createInviteUseCase = CreateInviteUseCase(ResidentRepositoryImpl()),
        _streamInvitesUseCase = StreamInvitesUseCase(ResidentRepositoryImpl()),
        _respondToVisitorAlertUseCase = RespondToVisitorAlertUseCase(ResidentRepositoryImpl()),
        _streamIncomingVisitorAlertsUseCase = StreamIncomingVisitorAlertsUseCase(ResidentRepositoryImpl()),
        _streamVisitorHistoryUseCase = StreamVisitorHistoryUseCase(ResidentRepositoryImpl());

  List<InviteEntity> get invites => _invites;
  List<CheckInEntity> get history => _history;
  CheckInEntity? get activeAlert => _activeAlert;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Initialize data queries once resident user profile is ready
  void initialize(String userId, String flatNumber) {
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

  void _stopListening() {
    _invitesSubscription?.cancel();
    _alertsSubscription?.cancel();
    _historySubscription?.cancel();
    _invites = [];
    _history = [];
    _activeAlert = null;
  }

  @override
  void dispose() {
    _stopListening();
    super.dispose();
  }
}
