import 'dart:io';
import 'package:ChatHub/model/user_info_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:video_compress/video_compress.dart';

import '../model/conversation_model.dart';
import '../model/status_model.dart';

class StatusController extends GetxController {

  RxList<StatusModel> myStatuses = <StatusModel>[].obs;

  RxMap<String, Map<String, dynamic>> friendsStatuses =
      <String, Map<String, dynamic>>{}.obs;

  RxBool isLoading = false.obs;
  // ─── Firebase ─────────────────────

  final firestore = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;
  final storage = FirebaseStorage.instance;

  // Cache to avoid repeated user fetching
  Map<String, UserInfoModel> userCache = {};

  // ─── Start ────────────────────────

  @override
  void onInit() {
    super.onInit();
    listenMyStatuses();
    loadFriendsStatuses();
  }

  // ─── My Statuses (real-time) ──────

  void listenMyStatuses() {
    final uid = auth.currentUser?.uid;
    if (uid == null) return;

    firestore
        .collection('statuses')
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      final list = <StatusModel>[];

      for (var doc in snapshot.docs) {
        final status = StatusModel.fromFirestore(doc);

        // ignore expired statuses
        if (!status.isExpired) {
          list.add(status);
        }
      }

      myStatuses.assignAll(list);
    });
  }

  // ─── Friends Statuses ─────────────

  Future<void> loadFriendsStatuses() async {
    isLoading.value = true;

    final uid = auth.currentUser?.uid;
    if (uid == null) return;

    // Step 1: get friends
    final friendIds = await getFriendIds(uid);

    if (friendIds.isEmpty) {
      isLoading.value = false;
      return;
    }

    // Step 2: load user names/photos
    await loadUsers(friendIds);

    // Step 3: load statuses
    final statuses = await loadStatuses(friendIds);

    // Step 4: group by user
    friendsStatuses.assignAll(groupByUser(statuses));

    isLoading.value = false;
  }

  // Get friend IDs from conversations
  Future<List<String>> getFriendIds(String uid) async {
    final sent = await firestore
        .collection('conversations')
        .where('user1_id', isEqualTo: uid)
        .get();

    final received = await firestore
        .collection('conversations')
        .where('user2_id', isEqualTo: uid)
        .get();

    final ids = <String>{};

    for (var doc in sent.docs) {
      final c = ConversationModel.fromJson(doc);
      ids.add(c.user2Id);
    }

    for (var doc in received.docs) {
      final c = ConversationModel.fromJson(doc);
      ids.add(c.user1Id);
    }

    return ids.toList();
  }

  // Load statuses of all friends (in chunks of 10)
  Future<List<StatusModel>> loadStatuses(List<String> userIds) async {
    final result = <StatusModel>[];

    final batches = split(userIds, 10);

    for (var batch in batches) {
      final snapshot = await firestore
          .collection('statuses')
          .where('userId', whereIn: batch)
          .orderBy('createdAt', descending: true)
          .get();

      for (var doc in snapshot.docs) {
        final status = StatusModel.fromFirestore(doc);

        if (!status.isExpired) {
          result.add(status);
        }
      }
    }

    return result;
  }

  // Group statuses by user
  Map<String, Map<String, dynamic>> groupByUser(List<StatusModel> list) {
    final map = <String, Map<String, dynamic>>{};

    for (var status in list) {
      final user = userCache[status.userId] ??
          UserInfoModel(name: "User ${status.userId.substring(0, 6)}");

      map.putIfAbsent(status.userId, () {
        return {
          'statuses': <StatusModel>[],
          'name': user.name,
          'photoUrl': user.photoUrl,
        };
      });

      map[status.userId]!['statuses'].add(status);
    }

    return map;
  }

  // Pick media and upload status
  Future<void> pickAndUploadMedia() async {
    final picker = ImagePicker();
    final file = await picker.pickMedia();

    if (file != null) {
      await addStatus(media: file);
    }
  }

  // ─── User cache ───────────────────

  Future<void> loadUsers(List<String> ids) async {
    final missing = ids.where((id) => !userCache.containsKey(id)).toList();
    if (missing.isEmpty) return;

    final batches = split(missing, 10);

    for (var batch in batches) {
      final snapshot = await firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: batch)
          .get();

      for (var doc in snapshot.docs) {
        final data = doc.data();

        userCache[doc.id] = UserInfoModel(
          name: data['name'] ?? 'Unknown',
          photoUrl: data['photoUrl'],
        );
      }
    }
  }

  // Split list into small parts
  List<List<T>> split<T>(List<T> list, int size) {
    final result = <List<T>>[];

    for (int i = 0; i < list.length; i += size) {
      int end = i + size;
      if (end > list.length) end = list.length;

      result.add(list.sublist(i, end));
    }

    return result;
  }

  // ─── Add new status ───────────────

  Future<void> addStatus({required XFile media, String? caption}) async {
    final uid = auth.currentUser?.uid;
    if (uid == null) return;

    try {
      final isVideo = media.path.endsWith('.mp4') ||
          media.path.endsWith('.mov');

      final ext = isVideo ? '.mp4' : '.jpg';

      final fileName = const Uuid().v4() + ext;

      // upload main file
      final ref = storage.ref().child('statuses/$uid/$fileName');
      await ref.putFile(File(media.path));
      final url = await ref.getDownloadURL();

      String? thumbUrl;

      // video thumbnail
      if (isVideo) {
        final thumb = await VideoCompress.getFileThumbnail(media.path);

        final thumbRef = storage.ref().child(
            'statuses/$uid/${const Uuid().v4()}_thumb.jpg');

        await thumbRef.putFile(thumb);
        thumbUrl = await thumbRef.getDownloadURL();

        await thumb.delete();
            }

      final now = Timestamp.now();

      final status = StatusModel(
        id: const Uuid().v4(),
        userId: uid,
        mediaUrl: url,
        type: isVideo ? 'video' : 'image',
        caption: caption,
        thumbnailUrl: thumbUrl,
        createdAt: now,
        expiresAt: Timestamp.fromDate(
          now.toDate().add(const Duration(hours: 24)),
        ),
      );

      await firestore.collection('statuses').doc(status.id).set(
        status.toFirestore(),
      );

      myStatuses.insert(0, status);

      Get.snackbar("Success", "Status uploaded");
    } catch (e) {
      Get.snackbar("Error", "Upload failed");
    }
  }
}