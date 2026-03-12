import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType { text, image, voice, video }

class MessageModel {
  final String conversationId;
  final String senderId;
  final String receiverId;
  final String? content;
  final String? mediaUrl;
  final MessageType type;
  final DateTime timestamp;
  final bool isSeen;

  MessageModel({
    required this.conversationId,
    required this.senderId,
    required this.receiverId,
    this.content,
    this.mediaUrl,
    this.type = MessageType.text,
    DateTime? timestamp,
    this.isSeen = false,
  }) : timestamp = timestamp ?? DateTime.now();

  MessageModel copyWith({
    String? conversationId,
    String? senderId,
    String? receiverId,
    String? content,
    DateTime? timestamp,
    bool? isSeen,
  }) {
    return MessageModel(
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isSeen: isSeen ?? this.isSeen,
    );
  }

  /// Factory constructor to create a MessageModel from JSON
  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      conversationId: json['conversation_id'],
      senderId: json['sender_id'],
      receiverId: json['receiver_id'],
      content: json['content'],
      mediaUrl: json['media_url'],
      type: MessageType.values.firstWhere(
            (e) => e.name == json['type'],
        orElse: () => MessageType.text,
      ),
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      isSeen: json['is_seen'] ?? false,
    );
  }

  /// Convert MessageModel to JSON for Firestore or API
  Map<String, dynamic> toJson() {
    return {
      'conversation_id': conversationId,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'content': content,
      'media_url': mediaUrl,
      'type': type.name,
      'timestamp': Timestamp.fromDate(timestamp),
      'is_seen': isSeen,
    };
  }
}