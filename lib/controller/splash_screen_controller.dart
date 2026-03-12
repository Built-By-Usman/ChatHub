import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constant/app_route.dart';


class SplashScreenController extends GetxController {
  @override
  void onInit() {
    checkLogin();
    super.onInit();
  }

  Future<void> checkLogin() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    // preferences.clear();

    bool isLoggedIn = preferences.getBool('is_logged_in') ?? false;
    if (isLoggedIn) {
      Future.delayed(const Duration(seconds: 2), () {
        Get.offAllNamed(AppRoute.home);
      });
    } else {
      Future.delayed(
        const Duration(seconds: 2),
        () => Get.toNamed(AppRoute.login),
      );
    }
  }
}
