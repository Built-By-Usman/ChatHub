import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String userId;
  final String phoneNumber;
  String? name;
  String? about;
  String? photoUrl;
  final bool? isActive;
  final Timestamp? createdAt;

  UserModel({
    required this.userId,
    required this.phoneNumber,
    this.name,
    this.about,
    this.photoUrl,
    this.isActive,
    this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'phone_number': phoneNumber,
      'name': name,
      'about': about,
      'photo_url': photoUrl,
      'is_active': isActive ?? true,
      'created_at': createdAt ?? FieldValue.serverTimestamp(),
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> map) {
    return UserModel(
      userId: map['user_id'] as String,
      phoneNumber: map['phone_number'] as String,
      name: map['name'] as String?,
      about: map['about'] as String?,
      photoUrl: map['photo_url'] as String?,
      isActive: map['is_active'] as bool?,
      createdAt: map['created_at'] as Timestamp?,
    );
  }
}