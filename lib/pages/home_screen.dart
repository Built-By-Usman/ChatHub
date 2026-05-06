import 'dart:ui';
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
      backgroundColor: AppColor.scaffoldBg,

      /// ─── Frosted Glass Bottom Nav ──────────────────────
      bottomNavigationBar: Obx(() => Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: SalomonBottomBar(
                  currentIndex: controller.selectedIndex.value,
                  onTap: controller.changeTab,
                  selectedItemColor: AppColor.primary,
                  unselectedItemColor: Colors.grey.shade500,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  items: [
                    _buildNavItem(
                      controller: controller,
                      index: 0,
                      filledIcon: "assets/images/icons/chat_filled.svg",
                      outlineIcon: "assets/images/icons/chat.svg",
                      label: "Chats",
                    ),
                    _buildNavItem(
                      controller: controller,
                      index: 1,
                      filledIcon: "assets/images/icons/status_filled.svg",
                      outlineIcon: "assets/images/icons/status.svg",
                      label: "Status",
                    ),
                    _buildNavItem(
                      controller: controller,
                      index: 2,
                      filledIcon: "assets/images/icons/profile_filled.svg",
                      outlineIcon: "assets/images/icons/profile.svg",
                      label: "Profile",
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      )),

      /// ─── Body with IndexedStack for performance ────────
      body: Obx(() => IndexedStack(
        index: controller.selectedIndex.value,
        children: controller.bottomBarViews,
      )),
    );
  }

  SalomonBottomBarItem _buildNavItem({
    required HomeScreenController controller,
    required int index,
    required String filledIcon,
    required String outlineIcon,
    required String label,
  }) {
    final isSelected = controller.selectedIndex.value == index;
    return SalomonBottomBarItem(
      icon: SvgPicture.asset(
        isSelected ? filledIcon : outlineIcon,
        width: 24,
        height: 24,
        colorFilter: ColorFilter.mode(
          isSelected ? AppColor.primary : Colors.grey.shade500,
          BlendMode.srcIn,
        ),
      ),
      title: Text(label),
      selectedColor: AppColor.primary,
    );
  }
}