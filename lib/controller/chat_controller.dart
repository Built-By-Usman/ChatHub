import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../core/constant/app_route.dart';
import '../model/chat_model.dart';
import '../model/conversation_model.dart';

class ChatScreenController extends GetxController {
  var isRecording = false.obs;
  String? recordedFilePath;
  RxList<ChatModel> chats = <ChatModel>[].obs;
  RxBool isLoading = false.obs;

  void goToDetailScreen(ChatModel chat) {
    Get.toNamed(
      AppRoute.chatDetail,
      arguments: {
        "conversation": chat.conversation,
      },
    );
  }

  void goToContactScreen() {
    Get.toNamed(AppRoute.contact);
  }

  @override
  void onInit() {
    super.onInit();
    fetchConversations();
  }
  final List<String> popMenuItems = [
    "New group",
    "New boradcast",
    "Whatsapp Web",
    "Stared messages",
    "Settings",
  ];

  // Selected pop-up menu
  String popUpMenu = "New group";


  // Update selected menu
  void selectPopMenu(String? value) {
    if (value != null) {
      popUpMenu = value;
      update();
    }
  }

  void goToCameraScreen() {
    Get.toNamed(AppRoute.login);
  }

  void fetchConversations() {
    try {
      isLoading.value = true;

      final currentUserId = FirebaseAuth.instance.currentUser!.uid;

      FirebaseFirestore.instance
          .collection('conversations')
          .orderBy('last_message_time', descending: true)
          .snapshots()
          .listen((snapshot) async {
        List<ChatModel> tempList = [];

        for (var doc in snapshot.docs) {
          final conversation = ConversationModel.fromJson(doc);

          // Skip conversations that don't include current user
          if (conversation.user1Id != currentUserId &&
              conversation.user2Id != currentUserId) {
            continue;
          }

          // Get the other user's ID
          final otherUserId = conversation.user1Id == currentUserId
              ? conversation.user2Id
              : conversation.user1Id;

          // Fetch other user data
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(otherUserId)
              .get();

          if (!userDoc.exists) continue;

          final userData = userDoc.data() as Map<String, dynamic>;

          tempList.add(
            ChatModel(
              otherUserId: otherUserId,
              name: userData['name'] ?? "Unknown",
              profilePicture: userData['photo_url'],
              lastMessage: conversation.lastMessage ?? "",
              lastMessageTime: conversation.lastMessageTime ?? DateTime.now(),
              isSeen: conversation.isSeen ?? false,
              conversation: conversation,
            ),
          );
        }

        // No need to sort again — Firestore already gave us newest first
        // tempList.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));

        chats.value = tempList;
        isLoading.value = false;
      });
    } catch (e) {
      print("Error fetching conversations real-time: $e");
      isLoading.value = false;
    }
  }
}