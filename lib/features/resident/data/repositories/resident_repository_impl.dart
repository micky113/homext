import 'dart:async';
import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/services/mock_data_service.dart';
import '../../../../core/utils/constants.dart';
import '../../../guard/domain/entities/checkin_entity.dart';
import '../../../guard/data/models/checkin_model.dart';
import '../../domain/entities/invite_entity.dart';
import '../../domain/repositories/resident_repository.dart';
import '../models/invite_model.dart';

class ResidentRepositoryImpl implements ResidentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final MockDataService _mockData = MockDataService();

  @override
  Stream<List<InviteEntity>> streamInvites(String userId) {
    if (AppConstants.useMockData) {
      return _mockData.invitesStream;
    }

    return _firestore
        .collection('residents')
        .doc(userId)
        .collection('invites')
        .orderBy('inviteDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => InviteModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  @override
  Future<InviteEntity> createInvite({
    required String userId,
    required String visitorName,
    required String purpose,
    required DateTime inviteDate,
    required String flatNumber,
    required String hostName,
  }) async {
    if (AppConstants.useMockData) {
      return await _mockData.createInvite(
        visitorName: visitorName,
        purpose: purpose,
        inviteDate: inviteDate,
        flatNumber: flatNumber,
        hostName: hostName,
      );
    }

    final docRef = _firestore
        .collection('residents')
        .doc(userId)
        .collection('invites')
        .doc();
    
    // Generate a simple invite code
    final code = 'MG-${(1000 + (9000 * (DateTime.now().millisecond / 1000))).toInt()}';
    
    final model = InviteModel(
      id: docRef.id,
      visitorName: visitorName,
      purpose: purpose,
      inviteDate: inviteDate,
      inviteCode: code,
      flatNumber: flatNumber,
      hostName: hostName,
    );

    await docRef.set(model.toMap());

    // Send notifications to society guards
    try {
      final residentDoc = await _firestore.collection('residents').doc(userId).get();
      if (residentDoc.exists) {
        final data = residentDoc.data();
        if (data != null && data['metadata'] != null) {
          final societyId = data['metadata']['societyId'];
          if (societyId != null) {
            final guardsQuery = await _firestore
                .collection('guards')
                .where('metadata.societyId', isEqualTo: societyId)
                .get();

            for (final guardDoc in guardsQuery.docs) {
              final guardData = guardDoc.data();
              final guardToken = guardData['fcmToken'];
              if (guardToken != null && guardToken.toString().isNotEmpty) {
                await _firestore.collection('notifications_queue').add({
                  'token': guardToken,
                  'title': 'New Pre-Approved Invite',
                  'body': 'Flat $flatNumber ($hostName) pre-approved entry for $visitorName ($purpose)',
                  'data': {
                    'type': 'PRE_APPROVED_ALERT',
                    'inviteId': docRef.id,
                    'visitorName': visitorName,
                    'flatNumber': flatNumber,
                    'hostName': hostName,
                    'inviteCode': code,
                  },
                  'timestamp': FieldValue.serverTimestamp(),
                });
              }
            }
          }
        }
      }
    } catch (e) {
      developer.log("Error enqueuing FCM guard notification for invite: $e");
    }

    return model;
  }

  @override
  Stream<CheckInEntity> streamIncomingAlerts(String flatNumber) {
    if (AppConstants.useMockData) {
      return _mockData.incomingAlertsStream;
    }

    // Query visitor_logs that are PENDING and match this resident's flat number
    return _firestore
        .collection('visitor_logs')
        .where('flatNumber', isEqualTo: flatNumber)
        .where('status', isEqualTo: 'PENDING')
        .snapshots()
        .transform(StreamTransformer<QuerySnapshot<Map<String, dynamic>>, CheckInEntity>.fromHandlers(
      handleData: (QuerySnapshot<Map<String, dynamic>> snapshot, EventSink<CheckInEntity> sink) {
        if (snapshot.docs.isNotEmpty) {
          final doc = snapshot.docs.first;
          sink.add(CheckInModel.fromMap(doc.data(), doc.id));
        }
      },
    ));
  }

  @override
  Stream<List<CheckInEntity>> streamVisitorHistory(String flatNumber) {
    if (AppConstants.useMockData) {
      return _mockData.checkinsStream.map((checkins) {
        return checkins.where((c) => c.flatNumber == flatNumber).toList();
      });
    }

    return _firestore
        .collection('visitor_logs')
        .where('flatNumber', isEqualTo: flatNumber)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => CheckInModel.fromMap(doc.data(), doc.id))
          .toList();
      list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return list;
    });
  }

  @override
  Future<void> respondToAlert({
    required String checkinId,
    required String status,
  }) async {
    if (AppConstants.useMockData) {
      return await _mockData.respondToAlert(checkinId, status);
    }

    await _firestore.collection('visitor_logs').doc(checkinId).update({
      'status': status,
    });
  }
}
