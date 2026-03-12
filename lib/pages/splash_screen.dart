import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../../../core/constant/app_color.dart';
import '../../../core/constant/app_image.dart';
import '../../../core/constant/app_size.dart';
import '../controller/splash_screen_controller.dart';
import '../widgets/spacer/spacer.dart';

class SplashScreen extends StatelessWidget {
  SplashScreen({super.key});

  final SplashScreenController controller = Get.put(SplashScreenController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColor.primary.withOpacity(.05), AppColor.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child:Column(
              children: [
                const Spacer(),
                SvgPicture.asset(
                  AppImage.splash,
                  width: AppSize.screenWidth! / 2,
                ),
                const Spacer(),
                Column(
                  children: [
                    const Text(
                      "from",
                      style: TextStyle(
                        color: AppColor.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          AppImage.meta,
                          width: 25,
                          color: AppColor.second,
                        ),
                        const HorizontalSpacer(0.3),
                        const Text(
                          "Abdullah Iqbal",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppColor.second,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const VerticalSpacer(3),
              ],
            )

        ),
      ),
    );
  }
}
