import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:video_compress/video_compress.dart';

import '../model/conversation_model.dart';
import '../model/status_model.dart';

class UserInfo {
  final String name;
  final String? photoUrl;

  UserInfo({required this.name, this.photoUrl});
}

class StatusController extends GetxController {
  // My statuses
  final RxList<StatusModel> myStatuses = <StatusModel>[].obs;

  // Friends' statuses + real user info
  final RxMap<String, Map<String, dynamic>> friendsStatuses = <String, Map<String, dynamic>>{}.obs;
  // Structure: { userId: { 'statuses': [...], 'name': '...', 'photoUrl': '...' } }

  final RxBool isLoading = false.obs;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Cache for user info (name + photo)
  final RxMap<String, UserInfo> _userCache = <String, UserInfo>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMyStatuses();
    fetchFriendsStatuses();
  }

  // Fetch my own statuses
  void fetchMyStatuses() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    _firestore
        .collection('statuses')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      final statuses = snapshot.docs
          .map((doc) => StatusModel.fromFirestore(doc))
          .where((s) => !s.isExpired)
          .toList();

      myStatuses.assignAll(statuses);
    });
  }

  // Fetch statuses from conversation friends + real names/photos
  Future<void> fetchFriendsStatuses() async {
    isLoading.value = true;

    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    // Get all friends from conversations
    final convQueries = await Future.wait([
      _firestore.collection('conversations').where('user1_id', isEqualTo: userId).get(),
      _firestore.collection('conversations').where('user2_id', isEqualTo: userId).get(),
    ]);

    final friendIds = <String>{};
    for (var snap in convQueries) {
      for (var doc in snap.docs) {
        final conv = ConversationModel.fromJson(doc);
        final otherId = conv.user1Id == userId ? conv.user2Id : conv.user1Id;
        friendIds.add(otherId);
      }
    }

    if (friendIds.isEmpty) {
      isLoading.value = false;
      return;
    }

    // Fetch real user info for all friends (cached)
    await _fetchUserInfo(friendIds.toList());

    // Fetch statuses in batches (Firestore whereIn limit = 10)
    final batches = _chunkList(friendIds.toList(), 10);
    final allStatuses = <StatusModel>[];

    for (var batch in batches) {
      final snap = await _firestore
          .collection('statuses')
          .where('userId', whereIn: batch)
          .orderBy('createdAt', descending: true)
          .get();

      allStatuses.addAll(
        snap.docs
            .map((doc) => StatusModel.fromFirestore(doc))
            .where((s) => !s.isExpired),
      );
    }

    // Group by userId + attach real name/photo
    final grouped = <String, Map<String, dynamic>>{};

    for (var status in allStatuses) {
      final userInfo = _userCache[status.userId] ??
          UserInfo(name: "User ${status.userId.substring(0, 6)}");

      grouped.putIfAbsent(status.userId, () => {
        'statuses': <StatusModel>[],
        'name': userInfo.name,
        'photoUrl': userInfo.photoUrl,
      });

      grouped[status.userId]!['statuses'].add(status);
    }

    friendsStatuses.assignAll(grouped);
    isLoading.value = false;
  }

  // Fetch user names & photos (cached)
  Future<void> _fetchUserInfo(List<String> userIds) async {
    final missingIds = userIds.where((id) => !_userCache.containsKey(id)).toList();

    if (missingIds.isEmpty) return;

    final batches = _chunkList(missingIds, 10);

    for (var batch in batches) {
      final snap = await _firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: batch)
          .get();

      for (var doc in snap.docs) {
        final data = doc.data();
        _userCache[doc.id] = UserInfo(
          name: data['name'] ?? 'Unknown User',
          photoUrl: data['photoUrl'],
        );
      }
    }
  }

  // Helper: Split list into chunks (for whereIn limit = 10)
  List<List<T>> _chunkList<T>(List<T> list, int size) {
    final chunks = <List<T>>[];
    for (var i = 0; i < list.length; i += size) {
      chunks.add(list.sublist(i, i + size > list.length ? list.length : i + size));
    }
    return chunks;
  }

  // Add new status (image/video) + thumbnail for video
  Future<void> addStatus({required XFile media, String? caption}) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      final isVideo = media.path.toLowerCase().endsWith('.mp4') ||
          media.path.toLowerCase().endsWith('.mov');

      final ext = isVideo ? '.mp4' : '.jpg';
      final fileName = const Uuid().v4() + ext;
      final thumbName = const Uuid().v4() + '_thumb.jpg';

      // Upload original media
      final mediaRef = _storage.ref().child('statuses/$userId/$fileName');
      await mediaRef.putFile(File(media.path));
      final mediaUrl = await mediaRef.getDownloadURL();

      String? thumbnailUrl;

      if (isVideo) {
        final thumbFile = await VideoCompress.getFileThumbnail(
          media.path,
          quality: 50,
          position: -1,
        );

        if (thumbFile != null) {
          final thumbRef = _storage.ref().child('statuses/$userId/$thumbName');
          await thumbRef.putFile(thumbFile);
          thumbnailUrl = await thumbRef.getDownloadURL();
          await thumbFile.delete();
        }
      }

      final now = Timestamp.now();
      final expires = Timestamp.fromDate(now.toDate().add(const Duration(hours: 24)));

      final status = StatusModel(
        id: const Uuid().v4(),
        userId: userId,
        mediaUrl: mediaUrl,
        type: isVideo ? 'video' : 'image',
        caption: caption,
        thumbnailUrl: thumbnailUrl,
        createdAt: now,
        expiresAt: expires,
      );

      await _firestore.collection('statuses').doc(status.id).set(status.toFirestore());

      // Instantly add to my list for better UX
      myStatuses.insert(0, status);

      Get.snackbar("Success", "Status added");
    } catch (e) {
      Get.snackbar("Error", "Failed to add status: $e");
      print("Status upload error: $e");
    }
  }
}