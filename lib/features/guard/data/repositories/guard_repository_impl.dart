import 'dart:async';
import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/services/mock_data_service.dart';
import '../../../../core/utils/constants.dart';
import '../../../resident/domain/entities/invite_entity.dart';
import '../../../resident/data/models/invite_model.dart';
import '../../domain/entities/checkin_entity.dart';
import '../../domain/repositories/guard_repository.dart';
import '../models/checkin_model.dart';

class GuardRepositoryImpl implements GuardRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final MockDataService _mockData = MockDataService();

  @override
  Stream<List<CheckInEntity>> streamRecentCheckins() {
    if (AppConstants.useMockData) {
      return _mockData.checkinsStream.map((list) {
        return list.where((c) => c.status != 'EXITED').toList();
      });
    }

    return _firestore
        .collection('visitor_logs')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => CheckInModel.fromMap(doc.data(), doc.id))
          .where((c) => c.status != 'EXITED')
          .toList();
    });
  }

  @override
  Future<CheckInEntity> checkInVisitor({
    required String visitorName,
    required String purpose,
    required String flatNumber,
    required String gateNumber,
    required String guardId,
  }) async {
    if (AppConstants.useMockData) {
      return await _mockData.checkInVisitor(
        visitorName: visitorName,
        purpose: purpose,
        flatNumber: flatNumber,
        gateNumber: gateNumber,
        guardId: guardId,
      );
    }

    final docRef = _firestore.collection('visitor_logs').doc();
    final model = CheckInModel(
      id: docRef.id,
      visitorName: visitorName,
      purpose: purpose,
      flatNumber: flatNumber,
      gateNumber: gateNumber,
      guardId: guardId,
      timestamp: DateTime.now(),
      status: 'PENDING',
    );

    // 1. Save visitor log to Firestore
    await docRef.set(model.toMap());

    // 2. Perform a transactional lookup to trigger notifications if needed.
    // Fetch user who matches the target flatNumber to get their fcmToken
    try {
      final query = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'RESIDENT')
          .where('metadata.flatNumber', isEqualTo: flatNumber)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final residentToken = query.docs.first.data()['fcmToken'];
        if (residentToken != null && residentToken.toString().isNotEmpty) {
          // In a real production backend, you would write a notification request to a '/notifications_queue' collection
          // which triggers a Cloud Function to send the FCM payload. Let's write that queue doc.
          await _firestore.collection('notifications_queue').add({
            'token': residentToken,
            'title': 'Incoming Visitor',
            'body': '$visitorName is at $gateNumber for $purpose',
            'data': {
              'type': 'VISITOR_ALERT',
              'checkinId': docRef.id,
              'visitorName': visitorName,
              'purpose': purpose,
              'flatNumber': flatNumber,
            },
            'timestamp': FieldValue.serverTimestamp(),
          });
        }
      }
    } catch (e) {
      // Log notification enqueue failure but do not crash the check-in process
      developer.log("Error enqueuing FCM alert notification: $e");
    }

    return model;
  }

  @override
  Stream<List<InviteEntity>> streamPreApprovedInvites() {
    if (AppConstants.useMockData) {
      return _mockData.invitesStream;
    }

    return _firestore
        .collectionGroup('invites')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => InviteModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  @override
  Future<CheckInEntity> checkInPreApprovedVisitor({
    required String inviteCode,
    required String gateNumber,
    required String guardId,
  }) async {
    if (AppConstants.useMockData) {
      return await _mockData.checkInPreApprovedVisitor(
        inviteCode: inviteCode,
        gateNumber: gateNumber,
        guardId: guardId,
      );
    }

    final querySnapshot = await _firestore
        .collectionGroup('invites')
        .where('inviteCode', isEqualTo: inviteCode.trim().toUpperCase())
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      throw Exception('Invalid or expired Invite Code. Please check the code.');
    }

    final inviteDoc = querySnapshot.docs.first;
    final invite = InviteModel.fromMap(inviteDoc.data(), inviteDoc.id);

    final docRef = _firestore.collection('visitor_logs').doc();
    final model = CheckInModel(
      id: docRef.id,
      visitorName: invite.visitorName,
      purpose: invite.purpose,
      flatNumber: invite.flatNumber.isNotEmpty ? invite.flatNumber : 'A-101',
      gateNumber: gateNumber,
      guardId: guardId,
      timestamp: DateTime.now(),
      status: 'APPROVED',
    );

    final batch = _firestore.batch();
    batch.set(docRef, model.toMap());
    batch.delete(inviteDoc.reference);
    await batch.commit();

    return model;
  }

  @override
  Future<void> exitVisitor(String checkinId) async {
    if (AppConstants.useMockData) {
      return await _mockData.exitVisitor(checkinId);
    }

    await _firestore.collection('visitor_logs').doc(checkinId).update({
      'status': 'EXITED',
      'exitTimestamp': FieldValue.serverTimestamp(),
    });
  }
}
