import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({
    required super.uid,
    required super.name,
    required super.role,
    required super.metadata,
    required super.fcmToken,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String docId) {
    return UserModel(
      uid: docId,
      name: map['name'] ?? '',
      role: map['role'] ?? 'RESIDENT',
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
      fcmToken: map['fcmToken'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'role': role,
      'metadata': metadata,
      'fcmToken': fcmToken,
    };
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? role,
    Map<String, dynamic>? metadata,
    String? fcmToken,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      role: role ?? this.role,
      metadata: metadata ?? this.metadata,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }
}
