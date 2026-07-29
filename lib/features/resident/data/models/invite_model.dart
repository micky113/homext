import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/invite_entity.dart';

class InviteModel extends InviteEntity {
  InviteModel({
    required super.id,
    required super.visitorName,
    required super.purpose,
    required super.inviteDate,
    required super.inviteCode,
    required super.flatNumber,
    required super.hostName,
  });

  factory InviteModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parsedTime;
    final ts = map['inviteDate'];
    if (ts is Timestamp) {
      parsedTime = ts.toDate();
    } else if (ts is String) {
      parsedTime = DateTime.parse(ts);
    } else if (ts is int) {
      parsedTime = DateTime.fromMillisecondsSinceEpoch(ts);
    } else {
      parsedTime = DateTime.now();
    }

    return InviteModel(
      id: docId,
      visitorName: map['visitorName'] ?? '',
      purpose: map['purpose'] ?? '',
      inviteDate: parsedTime,
      inviteCode: map['inviteCode'] ?? '',
      flatNumber: map['flatNumber'] ?? '',
      hostName: map['hostName'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'visitorName': visitorName,
      'purpose': purpose,
      'inviteDate': Timestamp.fromDate(inviteDate),
      'inviteCode': inviteCode,
      'flatNumber': flatNumber,
      'hostName': hostName,
    };
  }

  InviteModel copyWith({
    String? id,
    String? visitorName,
    String? purpose,
    DateTime? inviteDate,
    String? inviteCode,
    String? flatNumber,
    String? hostName,
  }) {
    return InviteModel(
      id: id ?? this.id,
      visitorName: visitorName ?? this.visitorName,
      purpose: purpose ?? this.purpose,
      inviteDate: inviteDate ?? this.inviteDate,
      inviteCode: inviteCode ?? this.inviteCode,
      flatNumber: flatNumber ?? this.flatNumber,
      hostName: hostName ?? this.hostName,
    );
  }
}
