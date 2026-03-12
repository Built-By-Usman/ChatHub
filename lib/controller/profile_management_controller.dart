import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../model/user_model.dart';

class ProfileManagementController extends GetxController {
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;

  final nameController = TextEditingController();
  final aboutController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  void onInit() {
    super.onInit();
    fetchCurrentUser();
  }

  Future<void> fetchCurrentUser() async {
    isLoading.value = true;

    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) {
        Get.snackbar("Error", "Not logged in");
        return;
      }

      final doc = await _firestore.collection('users').doc(uid).get();

      if (doc.exists) {
        currentUser.value = UserModel.fromJson(doc.data()!);
        nameController.text = currentUser.value?.name ?? '';
        aboutController.text = currentUser.value?.about ?? '';
      } else {
        Get.snackbar("Error", "User profile not found");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to load profile: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickAndUpdatePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    isSaving.value = true;

    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      final ref = _storage.ref().child('profile_photos/$uid.jpg');
      await ref.putFile(File(pickedFile.path));
      final photoUrl = await ref.getDownloadURL();

      await _firestore.collection('users').doc(uid).update({
        'photo_url': photoUrl,
      });

      currentUser.update((val) {
        val?.photoUrl = photoUrl;
      });

      Get.snackbar("Success", "Profile photo updated");
    } catch (e) {
      Get.snackbar("Error", "Failed to update photo: $e");
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> updateProfile() async {
    final name = nameController.text.trim();
    final about = aboutController.text.trim();

    if (name.isEmpty) {
      Get.snackbar("Error", "Name cannot be empty");
      return;
    }

    isSaving.value = true;

    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      await _firestore.collection('users').doc(uid).update({
        'name': name,
        'about': about,
      });

      currentUser.update((val) {
        val?.name = name;
        val?.about = about;
      });

      Get.snackbar("Success", "Profile updated");
      Get.back(); // Close screen after save
    } catch (e) {
      Get.snackbar("Error", "Failed to update profile: $e");
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    aboutController.dispose();
    super.onClose();
  }
}