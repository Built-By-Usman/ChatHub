import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/constant/app_color.dart';
import '../core/constant/app_route.dart';
import '../core/constant/app_string.dart';

class OnboardScreen extends StatelessWidget {
  const OnboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      body: SafeArea(
        child: Column(
          children: [

            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/images/onboard.png'),
                    const SizedBox(height: 20),
                    const Text(
                      'Welcome to ${AppString.appName}',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Read our privacy policy. Tap "Agree and continue" to accept',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary,
                  ),
                  onPressed: () {
                    Get.offNamed(AppRoute.login);
                  },
                  child: const Text(
                    "Agree and Continue",
                    style: TextStyle(color: AppColor.white, fontSize: 17),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );;
  }
}
