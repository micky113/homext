import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import '../../data/repositories/guard_repository_impl.dart';
import '../../../resident/domain/entities/invite_entity.dart';
import '../../domain/entities/checkin_entity.dart';
import '../../domain/usecases/checkin_visitor_usecase.dart';
import '../../domain/usecases/stream_recent_checkins_usecase.dart';
import '../../domain/usecases/stream_pre_approved_invites_usecase.dart';
import '../../domain/usecases/checkin_pre_approved_visitor_usecase.dart';
import '../../domain/usecases/exit_visitor_usecase.dart';

class GuardProvider extends ChangeNotifier {
  final CheckInVisitorUseCase _checkInVisitorUseCase;
  final StreamRecentCheckinsUseCase _streamRecentCheckinsUseCase;
  final StreamPreApprovedInvitesUseCase _streamPreApprovedInvitesUseCase;
  final CheckInPreApprovedVisitorUseCase _checkInPreApprovedVisitorUseCase;
  final ExitVisitorUseCase _exitVisitorUseCase;

  List<CheckInEntity> _checkins = [];
  List<InviteEntity> _preApprovedInvites = [];
  bool _isLoading = false;
  String? _errorMessage;

  InviteEntity? _latestNewInviteAlert;
  bool _isInitialInvitesLoad = true;

  InviteEntity? get latestNewInviteAlert => _latestNewInviteAlert;

  void clearInviteAlert() {
    _latestNewInviteAlert = null;
    notifyListeners();
  }

  StreamSubscription<List<CheckInEntity>>? _checkinsSubscription;
  StreamSubscription<List<InviteEntity>>? _invitesSubscription;

  GuardProvider()
      : _checkInVisitorUseCase = CheckInVisitorUseCase(GuardRepositoryImpl()),
        _streamRecentCheckinsUseCase = StreamRecentCheckinsUseCase(GuardRepositoryImpl()),
        _streamPreApprovedInvitesUseCase = StreamPreApprovedInvitesUseCase(GuardRepositoryImpl()),
        _checkInPreApprovedVisitorUseCase = CheckInPreApprovedVisitorUseCase(GuardRepositoryImpl()),
        _exitVisitorUseCase = ExitVisitorUseCase(GuardRepositoryImpl()) {
    _startListening();
  }

  List<CheckInEntity> get checkins => _checkins;
  List<InviteEntity> get preApprovedInvites => _preApprovedInvites;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _startListening() {
    _isLoading = true;
    
    // 1. Stream recent checkins feed
    _checkinsSubscription = _streamRecentCheckinsUseCase.call().listen(
      (data) {
        _checkins = data;
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

    // 2. Stream society invites
    _invitesSubscription = _streamPreApprovedInvitesUseCase.call().listen(
      (data) {
        if (!_isInitialInvitesLoad && data.length > _preApprovedInvites.length) {
          final newInvites = data.where((item) => !_preApprovedInvites.any((old) => old.id == item.id)).toList();
          if (newInvites.isNotEmpty) {
            _latestNewInviteAlert = newInvites.first;
          }
        }
        _preApprovedInvites = data;
        _isInitialInvitesLoad = false;
        notifyListeners();
      },
      onError: (err) {
        developer.log("Error streaming pre-approved invites: $err");
      },
    );
  }

  Future<bool> checkInVisitor({
    required String visitorName,
    required String purpose,
    required String flatNumber,
    required String gateNumber,
    required String guardId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _checkInVisitorUseCase.call(
        visitorName: visitorName,
        purpose: purpose,
        flatNumber: flatNumber,
        gateNumber: gateNumber,
        guardId: guardId,
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

  Future<bool> checkInPreApprovedVisitor({
    required String inviteCode,
    required String gateNumber,
    required String guardId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _checkInPreApprovedVisitorUseCase.call(
        inviteCode: inviteCode,
        gateNumber: gateNumber,
        guardId: guardId,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll(RegExp(r'Exception: '), '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> exitVisitor(String checkinId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _exitVisitorUseCase.call(checkinId);
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _checkinsSubscription?.cancel();
    _invitesSubscription?.cancel();
    super.dispose();
  }
}
