import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/contact_controller.dart';
import '../core/constant/app_color.dart';
import '../widgets/contact/components/custom_contact_item.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ContactScreenController());

    return Scaffold(
      backgroundColor: AppColor.scaffoldBg,
      appBar: AppBar(
        title: const Text("Select Contact"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          /// ─── Search Bar ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Container(
              decoration: BoxDecoration(
                color: AppColor.cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColor.dividerLight),
              ),
              child: Obx(() => TextField(
                cursorColor: AppColor.primary,
                controller: controller.searchController,
                keyboardType: TextInputType.phone,
                onChanged: (val) => controller.phoneNumber.value = val,
                decoration: InputDecoration(
                  hintText: 'Search by phone number...',
                  hintStyle: TextStyle(
                    color: AppColor.blueGrey.withValues(alpha: 0.4),
                    fontSize: 15,
                  ),
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColor.primary),
                  suffixIcon: controller.phoneNumber.value.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.close_rounded,
                            color: AppColor.blueGrey.withValues(alpha: 0.5),
                            size: 20,
                          ),
                          onPressed: () {
                            controller.searchController.clear();
                            controller.phoneNumber.value = '';
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  fillColor: Colors.transparent,
                  filled: false,
                ),
              )),
            ),
          ),

          /// ─── Results ─────────────────────────────────────
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColor.primary, strokeWidth: 2.5),
                );
              }

              if (controller.phoneNumber.value.isEmpty) {
                return _buildPlaceholder(
                  icon: Icons.person_search_rounded,
                  text: "Search for contacts",
                  subtext: "Enter a phone number with country code",
                );
              }

              if (controller.userList.isEmpty) {
                return _buildPlaceholder(
                  icon: Icons.search_off_rounded,
                  text: "No users found",
                  subtext: "Try a different phone number",
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 20),
                physics: const BouncingScrollPhysics(),
                itemCount: controller.userList.length,
                itemBuilder: (context, index) {
                  final user = controller.userList[index];
                  return CustomContactItem(
                    phoneNumber: user.phoneNumber,
                    photoUrl: user.photoUrl,
                    about: user.about,
                    onTap: () => controller.createConversation(index),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder({
    required IconData icon,
    required String text,
    required String subtext,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColor.primary.withValues(alpha: 0.06),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 48, color: AppColor.primary.withValues(alpha: 0.3)),
          ),
          const SizedBox(height: 20),
          Text(
            text,
            style: TextStyle(
              color: AppColor.blueGrey.withValues(alpha: 0.6),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtext,
            style: TextStyle(
              color: AppColor.blueGrey.withValues(alpha: 0.4),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}