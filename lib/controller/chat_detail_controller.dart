import 'dart:async';
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:uuid/uuid.dart';
import 'package:video_compress/video_compress.dart';
import '../../../model/message_model.dart';
import '../../../model/conversation_model.dart';
import '../../../model/user_model.dart';
import 'package:intl/intl.dart';
import 'package:ChatHub/controller/voice_player_controller.dart';

class ChatDetailScreenController extends GetxController {
  late ConversationModel conversation;
  final voiceController = Get.put(VoicePlayerController());
  var recordDuration = Duration.zero.obs;
  Timer? _recordTimer;
  late Stopwatch _stopwatch;
  var otherUser = Rxn<UserModel>();
  late String myId;
  var isLoading = false.obs;
  var isChatOpen = false.obs;
  final AudioRecorder _audioRecorder = AudioRecorder();
  var isRecording = false.obs;
  String? recordedFilePath;

  final focusNode = FocusNode();
  final messageController = TextEditingController();
  final scrollController = ScrollController();
  var messages = <MessageModel>[].obs;

  var isEmojiShow = false.obs;
  var isSend = false.obs;

  String selectedPopMenu = "Gallery";
  final bottomSheetItems = [
    {"text": "Gallery", "icon": Icons.image, "color": Colors.purple, "function": () {}},
    {"text": "File", "icon": Icons.insert_drive_file, "color": Colors.blue, "function": () {}},
    {"text": "Location", "icon": Icons.location_on, "color": Colors.green, "function": () {}},
    {"text": "Contact", "icon": Icons.person, "color": Colors.orange, "function": () {}},
  ];

  List<String> get popMenuItems =>
      bottomSheetItems.map((item) => item["text"] as String).toList();

  @override
  void onInit() {
    super.onInit();
    isChatOpen.value = true;
    conversation = Get.arguments["conversation"];
    myId = FirebaseAuth.instance.currentUser!.uid;

    _fetchOtherUser();
    _fetchMessages();

    focusNode.addListener(() {
      if (focusNode.hasFocus) isEmojiShow.value = false;
    });
  }

  Future<void> startRecording() async {
    if (await _audioRecorder.hasPermission()) {
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/${const Uuid().v4()}.m4a';

      await _audioRecorder.start(
        const RecordConfig(),
        path: path,
      );

      recordedFilePath = path;
      isRecording.value = true;

      _stopwatch = Stopwatch()..start();
      recordDuration.value = Duration.zero;

      _recordTimer?.cancel();
      _recordTimer = Timer.periodic(
        const Duration(milliseconds: 100),
            (timer) {
          recordDuration.value = _stopwatch.elapsed;
        },
      );
    }
  }

  Future<void> stopRecording() async {
    _recordTimer?.cancel();
    _stopwatch.stop();

    final path = await _audioRecorder.stop();
    isRecording.value = false;

    if (path != null && recordDuration.value > const Duration(seconds: 1)) {
      await sendVoiceMessage(path);
    } else {
      // Discard short recordings
      if (path != null) {
        File(path).delete();
      }
    }
  }

  String format(Duration d) {
    final minutes = d.inMinutes.toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  Future<void> sendVoiceMessage(String filePath) async {
    final chatId = "${conversation.user1Id}_${conversation.user2Id}";
    final fileName = const Uuid().v4();

    final storageRef = FirebaseStorage.instance
        .ref()
        .child("voice_messages")
        .child(chatId)
        .child("$fileName.m4a");

    await storageRef.putFile(File(filePath));
    final downloadUrl = await storageRef.getDownloadURL();

    final messagesRef = FirebaseFirestore.instance
        .collection('conversations')
        .doc(chatId)
        .collection('messages');

    final messageDoc = messagesRef.doc();

    final voiceMessage = MessageModel(
      conversationId: chatId,
      senderId: myId,
      receiverId: otherUser.value!.userId,
      mediaUrl: downloadUrl,
      type: MessageType.voice,
      isSeen: false,
    );

    final batch = FirebaseFirestore.instance.batch();

    batch.set(messageDoc, voiceMessage.toJson());

    batch.update(
      FirebaseFirestore.instance.collection('conversations').doc(chatId),
      {
        'last_message': "🎤 Voice message",
        'last_message_time': Timestamp.now(),
        'is_seen': false,
        'sender_id': myId,
      },
    );

    await batch.commit();
  }

  /// ---------------- USER LOGIC ----------------
  Future<void> _fetchOtherUser() async {
    try {
      String otherUserId =
      conversation.user1Id == myId ? conversation.user2Id : conversation.user1Id;

      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(otherUserId)
          .get();

      if (doc.exists) {
        otherUser.value = UserModel.fromJson(doc.data() as Map<String, dynamic>);
      } else {
        otherUser.value = UserModel(
          userId: otherUserId,
          phoneNumber: "",
          name: "Unknown",
          photoUrl: null,
          about: null,
        );
      }
    } catch (e) {
      print("Error fetching user: $e");
    }
  }

  String getUserName() => otherUser.value?.name ?? "Unknown";

  Stream<String> userStatusStream(String uid) {
    return FirebaseDatabase.instance
        .ref('status/$uid')
        .onValue
        .map((event) {
      if (!event.snapshot.exists) return "Offline";

      final data = Map<String, dynamic>.from(event.snapshot.value as Map);

      final bool isOnline = data['is_online'] ?? false;
      final int? lastSeenMillis = data['last_seen'];

      if (isOnline) return "Online";
      if (lastSeenMillis == null) return "Offline";

      final lastSeen = DateTime.fromMillisecondsSinceEpoch(lastSeenMillis);

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final lastSeenDate = DateTime(lastSeen.year, lastSeen.month, lastSeen.day);

      if (lastSeenDate == today) {
        return "Last seen today at ${DateFormat.jm().format(lastSeen)}";
      }

      if (lastSeenDate == yesterday) {
        return "Last seen yesterday at ${DateFormat.jm().format(lastSeen)}";
      }

      return "Last seen ${DateFormat.yMMMd().format(lastSeen)} at ${DateFormat.jm().format(lastSeen)}";
    });
  }

  String? getUserPhoto() => otherUser.value?.photoUrl;

  bool hasPhoto() => otherUser.value?.photoUrl != null && otherUser.value!.photoUrl!.isNotEmpty;

  /// ---------------- MESSAGE LOGIC ----------------

  Future<void> _fetchMessages() async {
    try {
      final chatId = "${conversation.user1Id}_${conversation.user2Id}";
      final messagesRef = FirebaseFirestore.instance
          .collection('conversations')
          .doc(chatId)
          .collection('messages');

      messagesRef.orderBy('timestamp', descending: false).snapshots().listen(
            (snapshot) async {
          // Convert docs to MessageModel
          final fetchedMessages = snapshot.docs
              .map((doc) => MessageModel.fromJson(doc.data()))
              .toList();

          messages.value = fetchedMessages;

          // --- Only mark as seen if chat is open ---
          if (isChatOpen.value) {
            final batch = FirebaseFirestore.instance.batch();
            bool shouldUpdateConversation = false;

            for (var doc in snapshot.docs) {
              final data = doc.data();
              final isSeen = data['is_seen'] ?? false;
              final receiverId = data['receiver_id'] ?? '';

              if (!isSeen && receiverId == myId) {
                batch.update(doc.reference, {'is_seen': true});
                shouldUpdateConversation = true;
              }
            }

            if (shouldUpdateConversation) {
              final conversationRef = FirebaseFirestore.instance
                  .collection('conversations')
                  .doc(chatId);
              batch.update(conversationRef, {'is_seen': true});
              await batch.commit();
            }
          }

          // Scroll to bottom
          scrollToBottom(animated: false); // scroll to latest message
        },
      );
    } catch (e) {
      print("Error fetching messages: $e");
    }
  }

  void scrollToBottom({bool animated = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;

      if (animated) {
        scrollController.animateTo(
          0, // scroll to start, because reverse = true
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      } else {
        scrollController.jumpTo(0);
      }
    });
  }


  Future<void> pickAndSendMedia() async {
    try {
      final picker = ImagePicker();

      // Let user choose image or video from gallery
      final XFile? file = await picker.pickMedia(
        imageQuality: 85,           // initial quality (we'll compress further)
        requestFullMetadata: true,
      );

      if (file == null) return;     // user canceled

      final filePath = file.path;
      final isVideo = filePath.toLowerCase().endsWith('.mp4') ||
          filePath.toLowerCase().endsWith('.mov');

      String? compressedPath;

      if (isVideo) {
        // Compress video
        compressedPath = await _compressVideo(filePath);
      } else {
        // Compress image
        compressedPath = await _compressImage(filePath);
      }

      if (compressedPath == null) {
        Get.snackbar("Error", "Failed to compress media");
        return;
      }

      // Upload to Firebase Storage
      final chatId = "${conversation.user1Id}_${conversation.user2Id}";
      final fileName = const Uuid().v4();
      final ext = isVideo ? '.mp4' : '.jpg';

      final storageRef = FirebaseStorage.instance
          .ref()
          .child("media_messages")
          .child(chatId)
          .child("$fileName$ext");

      await storageRef.putFile(File(compressedPath));
      final downloadUrl = await storageRef.getDownloadURL();

      // Clean up compressed file
      File(compressedPath).delete();

      // Determine message type
      final messageType = isVideo ? MessageType.video : MessageType.image;

      // Create message
      final messagesRef = FirebaseFirestore.instance
          .collection('conversations')
          .doc(chatId)
          .collection('messages');

      final messageDoc = messagesRef.doc();

      final mediaMessage = MessageModel(
        conversationId: chatId,
        senderId: myId,
        receiverId: otherUser.value!.userId,
        mediaUrl: downloadUrl,
        type: messageType,
        isSeen: false,
      );

      final batch = FirebaseFirestore.instance.batch();

      batch.set(messageDoc, mediaMessage.toJson());

      batch.update(
        FirebaseFirestore.instance.collection('conversations').doc(chatId),
        {
          'last_message': isVideo ? "🎥 Video" : "📷 Photo",
          'last_message_time': Timestamp.now(),
          'is_seen': false,
          'sender_id': myId,
        },
      );

      await batch.commit();

      // Scroll to bottom
      scrollToBottom(animated: true);

    } catch (e) {
      print("Error sending media: $e");
      Get.snackbar("Error", "Failed to send media: $e");
    }
  }

// Compress image (returns path to compressed file)
  Future<String?> _compressImage(String originalPath) async {
    try {
      final dir = await getTemporaryDirectory();
      final targetPath = '${dir.path}/${Uuid().v4()}_compressed.jpg';

      final result = await FlutterImageCompress.compressAndGetFile(
        originalPath,
        targetPath,
        quality: 70,           // 70% is good balance
        minWidth: 800,
        minHeight: 800,
        rotate: 0,
      );

      if (result == null) return null;
      return result.path;
    } catch (e) {
      print("Image compress error: $e");
      return null;
    }
  }

// Compress video (returns path to compressed file)
  Future<String?> _compressVideo(String originalPath) async {
    try {
      final info = await VideoCompress.compressVideo(
        originalPath,
        quality: VideoQuality.DefaultQuality,
        deleteOrigin: false,          // don't delete original
      );

      if (info == null || info.file == null) return null;

      return info.file!.path;
    } catch (e) {
      print("Video compress error: $e");
      return null;
    }
  }

  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    final chatId = "${conversation.user1Id}_${conversation.user2Id}";
    final messagesRef = FirebaseFirestore.instance
        .collection('conversations')
        .doc(chatId)
        .collection('messages');

    final messageDoc = messagesRef.doc(); // create a new document reference
    final newMessage = MessageModel(
      conversationId: chatId,
      senderId: myId,
      receiverId: otherUser.value!.userId,
      content: text,
      timestamp: DateTime.now(),
      isSeen: false,
    );

    try {
      // Use batch write to update both message and conversation atomically
      final batch = FirebaseFirestore.instance.batch();
      batch.set(messageDoc, newMessage.toJson());
      batch.update(FirebaseFirestore.instance.collection('conversations').doc(chatId), {
        'last_message': newMessage.content,
        'last_message_time': Timestamp.fromDate(newMessage.timestamp),
        'is_seen': false,
        'sender_id': myId,
      });

      await batch.commit();

      messageController.clear();
      isSend.value = false;

      // Scroll to bottom after sending
      scrollToBottom(animated: true);

      // Clear input only after batch commits
      messageController.clear();
      isSend.value = false;

      // Scroll to bottom
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent + 60,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      print("Error sending message: $e");
    }
  }

  void changeInput(String value) => isSend.value = value.trim().isNotEmpty;

  void toggleEmoji() => isEmojiShow.value = !isEmojiShow.value;

  void onEmojiSelected(Category? _, Emoji? emoji) {
    if (emoji == null) return;
    messageController.text += emoji.emoji;
    changeInput(messageController.text);
  }

  Future<bool> onWillPop() async {
    if (isEmojiShow.value) {
      isEmojiShow.value = false;
      return false;
    }
    return true;
  }

  /// ---------------- UI ACTIONS ----------------
  void back() => Get.back();
  void selectPopMenu(String value) => selectedPopMenu = value;

  @override
  void onClose() {
    isChatOpen.value = false;
    focusNode.dispose();
    messageController.dispose();
    scrollController.dispose();
    _recordTimer?.cancel();
    super.onClose();
  }
}