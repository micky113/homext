import 'dart:async';
import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/services/mock_data_service.dart';
import '../../../../core/utils/constants.dart';
import '../../../guard/domain/entities/checkin_entity.dart';
import '../../../guard/data/models/checkin_model.dart';
import '../../domain/entities/invite_entity.dart';
import '../../domain/entities/notice_entity.dart';
import '../../domain/repositories/resident_repository.dart';
import '../models/invite_model.dart';
import '../models/notice_model.dart';

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

  @override
  Stream<List<NoticeEntity>> streamNotices(String societyId) {
    if (AppConstants.useMockData) {
      return _mockData.noticesStream.map((notices) {
        return notices.where((n) => n.societyId == societyId).toList();
      });
    }

    return _firestore
        .collection('notices')
        .where('societyId', isEqualTo: societyId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => NoticeModel.fromMap(doc.data(), doc.id))
          .toList();
      list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return list;
    });
  }

  @override
  Future<void> postNotice({
    required String societyId,
    required String title,
    required String content,
    required String postedBy,
  }) async {
    if (AppConstants.useMockData) {
      return await _mockData.postNotice(
        societyId: societyId,
        title: title,
        content: content,
        postedBy: postedBy,
      );
    }

    final docRef = _firestore.collection('notices').doc();
    final model = NoticeModel(
      id: docRef.id,
      title: title,
      content: content,
      timestamp: DateTime.now(),
      societyId: societyId,
      postedBy: postedBy,
    );

    await docRef.set(model.toMap());
  }

  @override
  Future<void> payDues({required String userId}) async {
    if (AppConstants.useMockData) {
      return await _mockData.payDues(userId);
    }

    await _firestore.collection('residents').doc(userId).update({
      'metadata.maintenancePaid': 'true',
      'metadata.charges': [],
      'metadata.pendingDues': '0',
      'metadata.paymentStatus': 'paid',
      'metadata.paymentRemarks': '',
    });
  }

  @override
  Future<void> rejectPayment({required String userId}) async {
    if (AppConstants.useMockData) {
      return await _mockData.rejectPayment(userId);
    }

    await _firestore.collection('residents').doc(userId).update({
      'metadata.paymentStatus': 'unpaid',
      'metadata.paymentRemarks': '',
    });
  }

  @override
  Future<void> submitPaymentVerification({required String userId, required String remarks}) async {
    if (AppConstants.useMockData) {
      return await _mockData.submitPaymentVerification(userId, remarks);
    }

    await _firestore.collection('residents').doc(userId).update({
      'metadata.paymentStatus': 'pending_confirmation',
      'metadata.paymentRemarks': remarks,
    });
  }

  @override
  Stream<String> streamMonthlyMaintenance(String societyId) {
    if (AppConstants.useMockData) {
      return _mockData.streamMonthlyMaintenance(societyId);
    }

    return _firestore
        .collection('societies')
        .doc(societyId)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return doc.data()?['monthlyMaintenance']?.toString() ?? '2500';
      }
      return '2500';
    });
  }

  @override
  Future<void> updateMonthlyMaintenance({required String societyId, required String amount}) async {
    if (AppConstants.useMockData) {
      return await _mockData.updateMonthlyMaintenance(societyId, amount);
    }

    await _firestore.collection('societies').doc(societyId).set({
      'monthlyMaintenance': amount,
    }, SetOptions(merge: true));
  }

  @override
  Future<void> addCustomCharge({required String userId, required String title, required String amount}) async {
    if (AppConstants.useMockData) {
      return await _mockData.addCustomCharge(userId, title, amount);
    }

    final docRef = _firestore.collection('residents').doc(userId);
    final docSnap = await docRef.get();
    if (docSnap.exists) {
      final data = docSnap.data();
      final metadata = Map<String, dynamic>.from(data?['metadata'] as Map? ?? {});
      
      final currentPending = double.tryParse(metadata['pendingDues']?.toString() ?? '0') ?? 0.0;
      final chargeAmt = double.tryParse(amount) ?? 0.0;
      final newPending = currentPending + chargeAmt;
      
      final charge = {
        'id': 'charge-${DateTime.now().millisecondsSinceEpoch}',
        'title': title,
        'amount': amount,
      };

      await docRef.update({
        'metadata.charges': FieldValue.arrayUnion([charge]),
        'metadata.pendingDues': newPending.toStringAsFixed(0),
        'metadata.paymentStatus': 'unpaid',
        'metadata.paymentRemarks': '',
      });
    }
  }

  @override
  Future<void> generateMonthlyBills({required String societyId}) async {
    if (AppConstants.useMockData) {
      return await _mockData.generateMonthlyBills(societyId);
    }

    final query = await _firestore
        .collection('residents')
        .where('metadata.societyId', isEqualTo: societyId)
        .get();

    // Query fixed monthly maintenance amount
    final societyDoc = await _firestore.collection('societies').doc(societyId).get();
    final fixedFee = double.tryParse(societyDoc.data()?['monthlyMaintenance']?.toString() ?? '2500') ?? 2500.0;

    final batch = _firestore.batch();
    for (final doc in query.docs) {
      final data = doc.data();
      final metadata = Map<String, dynamic>.from(data['metadata'] as Map? ?? {});
      final currentPending = double.tryParse(metadata['pendingDues']?.toString() ?? '0') ?? 0.0;
      final newPending = currentPending + fixedFee;

      batch.update(doc.reference, {
        'metadata.maintenancePaid': 'false',
        'metadata.pendingDues': newPending.toStringAsFixed(0),
        'metadata.paymentStatus': 'unpaid',
        'metadata.paymentRemarks': '',
      });
    }
    await batch.commit();
  }

  @override
  Future<void> billSpecialCharge({required String societyId, required String title, required String amount}) async {
    if (AppConstants.useMockData) {
      return await _mockData.billSpecialCharge(societyId, title, amount);
    }

    final query = await _firestore
        .collection('residents')
        .where('metadata.societyId', isEqualTo: societyId)
        .get();

    final fee = double.tryParse(amount) ?? 0.0;
    final charge = {
      'id': 'charge-${DateTime.now().millisecondsSinceEpoch}',
      'title': title,
      'amount': amount,
    };

    final batch = _firestore.batch();
    for (final doc in query.docs) {
      final data = doc.data();
      final metadata = Map<String, dynamic>.from(data['metadata'] as Map? ?? {});
      final currentPending = double.tryParse(metadata['pendingDues']?.toString() ?? '0') ?? 0.0;
      final newPending = currentPending + fee;

      batch.update(doc.reference, {
        'metadata.charges': FieldValue.arrayUnion([charge]),
        'metadata.pendingDues': newPending.toStringAsFixed(0),
        'metadata.paymentStatus': 'unpaid',
        'metadata.paymentRemarks': '',
      });
    }
    await batch.commit();
  }
}
