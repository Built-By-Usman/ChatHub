import 'package:ChatHub/core/constant/app_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/functions/my_snackbar.dart';
import '../model/user_model.dart';

class LoginController extends GetxController {
  // Observables
  var phoneNumber = ''.obs;
  var otp = ''.obs;
  var isLoading = false.obs;
  var isOtpSent = false.obs;
  var isFormValid = false.obs;

  // Controllers
  final phoneController = TextEditingController();
  final otpController = TextEditingController();

  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore db = FirebaseFirestore.instance;

  // Validate phone (simple check: length >= 10 digits)
  bool validatePhone(String value) {
    return value.replaceAll(RegExp(r'\D'), '').length >= 10;
  }

  void sendOtp() async {
    if (!validatePhone(phoneNumber.value)) {
      MySnackBar.showSnackBar('Error', 'Invalid Phone Number');
      return;
    }

    isLoading.value == true;
    auth.setSettings(appVerificationDisabledForTesting: true);
    await auth.verifyPhoneNumber(
      phoneNumber: phoneNumber.value,
      timeout: Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        await auth.signInWithCredential(credential);
        isLoading.value = false;
        MySnackBar.showSnackBar('Success', 'Phone automatically verified');
      },
      verificationFailed: (FirebaseAuthException e) {
        isLoading.value = false;
        MySnackBar.showSnackBar('Error', e.message ?? 'Verification failed');
      },
      codeSent: (String verificationId, int? respondToken) {
        isLoading.value = false;
        isOtpSent.value = true;
        MySnackBar.showSnackBar('Success', 'OTP sent');
        _verificationId = verificationId;
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  String? _verificationId;

  void verifyOtp() async {
    if (otpController.text.isEmpty) {
      MySnackBar.showSnackBar('Error', 'Please enter OTP');
      return;
    }
    isLoading.value = true;
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otpController.text.trim(),
      );
      await auth.signInWithCredential(credential);
      final SharedPreferences preferences =
          await SharedPreferences.getInstance();
      preferences.setString('user_id', auth.currentUser!.uid);
      preferences.setString('phone_number', phoneNumber.value);

      var existingUser = await db
          .collection('users')
          .doc(auth.currentUser!.uid)
          .get();
      if (!existingUser.exists) {
        UserModel user = UserModel(
          userId: auth.currentUser!.uid,
          phoneNumber: phoneNumber.value,
        );

        await db
            .collection('users')
            .doc(auth.currentUser!.uid)
            .set(user.toJson());
      }

      isLoading.value = false;

      Get.offAllNamed(AppRoute.profileSetup);
      MySnackBar.showSnackBar('Success', 'Phone number verified');
    } catch (e) {
      isLoading.value = false;
      MySnackBar.showSnackBar('Error', 'Invalid OTP');
    }
  }

  @override
  void onClose() {
    phoneController.dispose();
    otpController.dispose();
    super.onClose();
  }
}
