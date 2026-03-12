import 'package:cloud_firestore/cloud_firestore.dart';

class StatusModel {
  final String id;                    // Firestore document ID
  final String userId;                // Who posted this status
  final String? mediaUrl;             // URL of image or video
  final String? type;                 // "image" or "video" (or null for text-only status)
  final String? caption;              // Optional text/caption
  final Timestamp createdAt;          // When status was created
  final Timestamp expiresAt;          // createdAt + 24 hours
  final List<String> seenBy;
  final String? thumbnailUrl; // ← new field for video thumbnail// List of user IDs who viewed it

  StatusModel({
    required this.id,
    required this.userId,
    this.mediaUrl,
    this.type,
    this.caption,
    required this.createdAt,
    required this.expiresAt,
    this.thumbnailUrl,
    this.seenBy = const [],
  });

  factory StatusModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return StatusModel(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      mediaUrl: data['mediaUrl'] as String?,
      type: data['type'] as String?,
      caption: data['caption'] as String?,
      createdAt: data['createdAt'] as Timestamp? ?? Timestamp.now(),
      expiresAt: data['expiresAt'] as Timestamp? ?? Timestamp.now(),
      thumbnailUrl: data['thumbnailUrl'] as String?,
      seenBy: List<String>.from(data['seenBy'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      if (mediaUrl != null) 'mediaUrl': mediaUrl,
      if (type != null) 'type': type,
      if (caption != null) 'caption': caption,
      'createdAt': createdAt,
      'expiresAt': expiresAt,
      if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
      'seenBy': seenBy,
    };
  }

  /// Helper: Check if status is expired (older than 24 hours)
  bool get isExpired {
    return expiresAt.toDate().isBefore(DateTime.now());
  }

  /// Helper: Check if current user has seen this status
  bool hasSeen(String currentUserId) {
    return seenBy.contains(currentUserId);
  }

  /// Helper: Mark as seen by current user (returns updated list)
  List<String> markAsSeen(String currentUserId) {
    if (!seenBy.contains(currentUserId)) {
      return [...seenBy, currentUserId];
    }
    return seenBy;
  }

  /// Factory to create a new status (when user posts)
  factory StatusModel.create({
    required String userId,
    String? mediaUrl,
    String? type,
    String? caption,
  }) {
    final now = Timestamp.now();
    final expires = Timestamp.fromDate(now.toDate().add(const Duration(hours: 24)));

    return StatusModel(
      id: '', // Will be set by Firestore when added
      userId: userId,
      mediaUrl: mediaUrl,
      type: type,
      caption: caption,
      createdAt: now,
      expiresAt: expires,
      seenBy: [],
    );
  }
}