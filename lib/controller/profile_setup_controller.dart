import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image/image.dart' as img;
import 'package:ChatHub/core/constant/app_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/functions/my_snackbar.dart';

class ProfileSetupController extends GetxController {
  final nameController = TextEditingController();
  var name = ''.obs;
  var isLoading = false.obs;
  var imageFile = Rx<File?>(null);

  RxString currentName = ''.obs;
  RxString currentProfileUrl = ''.obs;

  final picker = ImagePicker();
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File file = File(pickedFile.path);

      if (file.lengthSync() > 5 * 1024 * 1024) {
        MySnackBar.showSnackBar('Error', 'File size cannot exceed 5 MB');
        return;
      }

      // Decode image
      img.Image? image = img.decodeImage(file.readAsBytesSync());
      if (image == null) return;

      // Resize very large images to a web-friendly size first.
      if (image.width > 1024 || image.height > 1024) {
        image = img.copyResize(image, width: 1024);
      }

      // Compress the result before upload to speed profile picture storage and download.
      final compressedBytes = img.encodeJpg(image, quality: 80);

      // Overwrite original file with compressed version
      final compressedFile = File(file.path)..writeAsBytesSync(compressedBytes);

      imageFile.value = compressedFile;
    }
  }

  Future<void> saveProfile() async {
    if (name.value.isEmpty) {
      MySnackBar.showSnackBar('Error', 'Please Enter a Name');
      return;
    }

    final user = auth.currentUser;
    if (user == null) {
      MySnackBar.showSnackBar('Error', 'User not authenticated');
      return;
    }

    try {
      isLoading.value = true;

      String? photoUrl = currentProfileUrl.value;

      /// Upload new image if selected
      if (imageFile.value != null) {
        final storageRef = FirebaseStorage.instance.ref().child(
          'profile_pictures/${user.uid}.jpg',
        );

        await storageRef.putFile(imageFile.value!);
        photoUrl = await storageRef.getDownloadURL();
      }

      /// Update Firestore
      await db.collection('users').doc(user.uid).update({
        'name': name.value,
        'photo_url': photoUrl,
      });

      final preferences = await SharedPreferences.getInstance();
      preferences.setString('name', name.value);

      preferences.setString('photo_url', photoUrl);

      preferences.setBool('is_logged_in', true);

      // FirebaseMessaging.instance.getToken().then((token) {
      //   if (token != null) {
      //     FirebaseFirestore.instance
      //         .collection('users')
      //         .doc(auth.currentUser!.uid)
      //         .update({'fcmToken': token});
      //   }
      // });

      Get.offAllNamed(AppRoute.home);
    } catch (e) {
      MySnackBar.showSnackBar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onInit() {
    fetchUserData();
    super.onInit();
  }

  Future<void> fetchUserData() async {
    var user = await db.collection('users').doc(auth.currentUser!.uid).get();
    if (user.exists) {
      currentName.value = user['name'] ?? '';
      currentProfileUrl.value = user['photo_url'] ?? '';
      nameController.text = currentName.value;
      name.value = currentName.value;

      if (currentProfileUrl.value.isNotEmpty) {
        CachedNetworkImageProvider(
          currentProfileUrl.value,
        ).resolve(const ImageConfiguration());
      }
    }
  }
}
