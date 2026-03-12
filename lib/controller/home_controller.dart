import 'package:ChatHub/pages/chat_screen.dart';
import 'package:ChatHub/pages/profile_management.dart';
import 'package:ChatHub/pages/status_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeScreenController extends GetxController {

  var isLoading = false.obs;
  var selectedIndex=0.obs;
  final FirebaseAuth auth =FirebaseAuth.instance;
  final FirebaseFirestore db = FirebaseFirestore.instance;


  @override
  void onInit() {
    super.onInit();
    updateOnlineStatus();

  }

  Future<void>updateOnlineStatus()async{
    await db.collection('users').doc(auth.currentUser!.uid).update({
      'is_online':true
    });


  }

  // Screens for TabBarView
  final List<Widget> bottomBarViews = const [
    ChatScreen(),
    StatusScreen(),
    ProfileManagement()


  ];

  void changeTab(int index){
    selectedIndex.value=index;
  }

  @override
  void onClose() {
    super.onClose();
    updateOnlineStatusOnClose();

  }
  Future<void> updateOnlineStatusOnClose()async{
    await db.collection('users').doc(auth.currentUser!.uid).update({
      'is_online':false,
      'last_seen':Timestamp.now()

    });
  }
}