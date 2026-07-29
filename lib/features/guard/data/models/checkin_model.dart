import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/checkin_entity.dart';

class CheckInModel extends CheckInEntity {
  CheckInModel({
    required super.id,
    required super.visitorName,
    required super.purpose,
    required super.flatNumber,
    required super.gateNumber,
    required super.guardId,
    required super.timestamp,
    required super.status,
  });

  factory CheckInModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parsedTime;
    final ts = map['timestamp'];
    if (ts is Timestamp) {
      parsedTime = ts.toDate();
    } else if (ts is String) {
      parsedTime = DateTime.parse(ts);
    } else if (ts is int) {
      parsedTime = DateTime.fromMillisecondsSinceEpoch(ts);
    } else {
      parsedTime = DateTime.now();
    }

    return CheckInModel(
      id: docId,
      visitorName: map['visitorName'] ?? '',
      purpose: map['purpose'] ?? '',
      flatNumber: map['flatNumber'] ?? '',
      gateNumber: map['gateNumber'] ?? '',
      guardId: map['guardId'] ?? '',
      timestamp: parsedTime,
      status: map['status'] ?? 'PENDING',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'visitorName': visitorName,
      'purpose': purpose,
      'flatNumber': flatNumber,
      'gateNumber': gateNumber,
      'guardId': guardId,
      'timestamp': Timestamp.fromDate(timestamp),
      'status': status,
    };
  }

  CheckInModel copyWith({
    String? id,
    String? visitorName,
    String? purpose,
    String? flatNumber,
    String? gateNumber,
    String? guardId,
    DateTime? timestamp,
    String? status,
  }) {
    return CheckInModel(
      id: id ?? this.id,
      visitorName: visitorName ?? this.visitorName,
      purpose: purpose ?? this.purpose,
      flatNumber: flatNumber ?? this.flatNumber,
      gateNumber: gateNumber ?? this.gateNumber,
      guardId: guardId ?? this.guardId,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
    );
  }
}
