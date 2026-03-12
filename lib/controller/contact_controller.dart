import 'package:ChatHub/core/constant/app_route.dart';
import 'package:ChatHub/model/conversation_model.dart';
import 'package:ChatHub/routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../model/user_model.dart';

class ContactScreenController extends GetxController {
  final searchController = TextEditingController();
  var isLoading = false.obs;
  final FirebaseFirestore db = FirebaseFirestore.instance;
  var phoneNumber = ''.obs;
  final RxList<UserModel> userList = <UserModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Whenever phoneNumber changes, search users
    ever(phoneNumber, (_) => searchUser());
  }

  Future<void> searchUser() async {
    final query = phoneNumber.value.trim();

    if (query.isEmpty) {
      userList.clear();
      return;
    }

    isLoading.value = true;

    try {
      final snapshot = await db
          .collection('users')
          .where('phone_number', isEqualTo: query)
          .get();

      // Exclude current user
      final currentUserId = FirebaseAuth.instance.currentUser!.uid;

      userList.value = snapshot.docs
          .where((doc) => doc.id != currentUserId) // exclude yourself
          .map((doc) => UserModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      userList.clear();
      print('Error fetching users: $e');
    }

    isLoading.value = false;
  }
  Future<void> createConversation(int index) async {
    try {
      UserModel user = userList[index];
      String u1Id = FirebaseAuth.instance.currentUser!.uid;
      String u2Id = user.userId;

      // Sort IDs alphabetically to create a unique document ID
      List<String> ids = [u1Id, u2Id]..sort();
      String docId = "${ids[0]}_${ids[1]}";

      // Check if conversation exists
      DocumentSnapshot doc = await db.collection('conversations').doc(docId).get();

      ConversationModel conversation;

      if (doc.exists) {
        conversation = ConversationModel.fromJson(doc);
      } else {
        conversation = ConversationModel(
          user1Id: u1Id,
          user2Id: u2Id,
          photoUrl: user.photoUrl,
        );

        await db.collection('conversations').doc(docId).set(conversation.toJson());
      }

      // Navigate to chat detail
      Get.offNamed(
        AppRoute.chatDetail,
        arguments: {"conversation": conversation, "myId": u1Id},
      );
    } on FirebaseException catch (e) {
      print("Error creating conversation: ${e.message}");
    }
  }}

// Action buttons like "New Group" etc
final List<Map<String, dynamic>> buttonsItems = [
  {
    "name": "New group",
    "icon": Icons.group,
    "function": () {
      // Example: navigate to group creation
    },
  },
  {"name": "New contact", "icon": Icons.person_add, "function": () {}},
];
