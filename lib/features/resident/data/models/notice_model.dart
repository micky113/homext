import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/notice_entity.dart';

class NoticeModel extends NoticeEntity {
  NoticeModel({
    required super.id,
    required super.title,
    required super.content,
    required super.timestamp,
    required super.societyId,
    required super.postedBy,
  });

  factory NoticeModel.fromMap(Map<String, dynamic> map, String docId) {
    final ts = map['timestamp'];
    final parsedTime = ts is Timestamp
        ? ts.toDate()
        : ts is String
            ? DateTime.tryParse(ts) ?? DateTime.now()
            : DateTime.now();

    return NoticeModel(
      id: docId,
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      timestamp: parsedTime,
      societyId: map['societyId'] ?? '',
      postedBy: map['postedBy'] ?? 'Admin',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
      'societyId': societyId,
      'postedBy': postedBy,
    };
  }

  NoticeModel copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? timestamp,
    String? societyId,
    String? postedBy,
  }) {
    return NoticeModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      societyId: societyId ?? this.societyId,
      postedBy: postedBy ?? this.postedBy,
    );
  }
}
