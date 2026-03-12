import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import '../controller/home_controller.dart';
import '../core/constant/app_color.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeScreenController controller = Get.put(HomeScreenController());

    return Scaffold(
      // ----------------- Bottom Navigation -----------------
      bottomNavigationBar: Obx(() => Container(
        decoration: BoxDecoration(
          color: AppColor.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
            ),
          ],
        ),
         child: SalomonBottomBar(
            currentIndex: controller.selectedIndex.value,
            onTap: controller.changeTab,
            selectedItemColor: AppColor.primary,
            unselectedItemColor: Colors.grey.shade600,

            items: [

              /// Chats
              SalomonBottomBarItem(
                icon: SvgPicture.asset(
                  controller.selectedIndex.value == 0
                      ? "assets/images/icons/chat_filled.svg"
                      : "assets/images/icons/chat.svg",
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    controller.selectedIndex.value == 0
                        ? AppColor.primary
                        : Colors.grey.shade600,
                    BlendMode.srcIn,
                  ),
                ),
                title: const Text("Chats"),
                selectedColor: AppColor.primary,
              ),

              /// Status
              SalomonBottomBarItem(
                icon: SvgPicture.asset(
                  controller.selectedIndex.value == 1
                      ? "assets/images/icons/status_filled.svg"
                      : "assets/images/icons/status.svg",
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    controller.selectedIndex.value == 1
                        ? AppColor.primary
                        : Colors.grey.shade600,
                    BlendMode.srcIn,
                  ),
                ),
                title: const Text("Status"),
                selectedColor: AppColor.primary,
              ),

              /// Profile
              SalomonBottomBarItem(
                icon: SvgPicture.asset(
                  controller.selectedIndex.value == 2
                      ? "assets/images/icons/profile_filled.svg"
                      : "assets/images/icons/profile.svg",
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    controller.selectedIndex.value == 2
                        ? AppColor.primary
                        : Colors.grey.shade600,
                    BlendMode.srcIn,
                  ),
                ),
                title: const Text("Profile"),
                selectedColor: AppColor.primary,
              ),
            ],
          )
      )
      ),

      // ----------------- Body -----------------
      body:Obx(()=>controller.bottomBarViews[controller.selectedIndex.value])


    );
  }
}