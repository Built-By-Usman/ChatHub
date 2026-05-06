import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/profile_management_controller.dart';
import '../core/constant/app_color.dart';

class ProfileManagement extends StatelessWidget {
  const ProfileManagement({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileManagementController());

    return Scaffold(
      backgroundColor: AppColor.scaffoldBg,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppColor.primary, strokeWidth: 2.5),
            );
          }

          final user = controller.currentUser.value;
          if (user == null) {
            return const Center(child: Text("Profile not found"));
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              children: [
                /// ─── Header ────────────────────────────────
                Text(
                  'Profile',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColor.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage your personal details',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),

                const SizedBox(height: 32),

                /// ─── Avatar ────────────────────────────────
                Center(
                  child: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              AppColor.primary.withValues(alpha: 0.2),
                              AppColor.third.withValues(alpha: 0.15),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: SizedBox(
                          width: 130,
                          height: 130,
                          child: user.photoUrl != null
                              ? CachedNetworkImage(
                                  imageUrl: user.photoUrl!,
                                  imageBuilder: (context, imageProvider) => CircleAvatar(
                                    radius: 65,
                                    backgroundImage: imageProvider,
                                  ),
                                  placeholder: (context, url) => CircleAvatar(
                                    radius: 65,
                                    backgroundColor: AppColor.inputFill,
                                    child: const CircularProgressIndicator(
                                      color: AppColor.primary,
                                      strokeWidth: 2.5,
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => const CircleAvatar(
                                    radius: 65,
                                    backgroundColor: AppColor.inputFill,
                                    child: Icon(Icons.person_rounded, size: 56, color: AppColor.blueGrey),
                                  ),
                                )
                              : const CircleAvatar(
                                  radius: 65,
                                  backgroundColor: AppColor.inputFill,
                                  child: Icon(Icons.person_rounded, size: 56, color: AppColor.blueGrey),
                                ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: controller.pickAndUpdatePhoto,
                          child: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColor.primary, AppColor.second],
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColor.primary.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.camera_alt_rounded, size: 18, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                /// ─── Info Card ──────────────────────────────
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColor.cardBg,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColor.dividerLight),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Personal Information',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColor.primary,
                        ),
                      ),
                      const SizedBox(height: 16),

                      /// Name
                      TextField(
                        controller: controller.nameController,
                        textCapitalization: TextCapitalization.words,
                        cursorColor: AppColor.primary,
                        decoration: InputDecoration(
                          labelText: "Full Name",
                          prefixIcon: const Icon(Icons.person_rounded, color: AppColor.primary),
                          filled: true,
                          fillColor: AppColor.inputFill,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: AppColor.primary, width: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      /// About
                      TextField(
                        controller: controller.aboutController,
                        cursorColor: AppColor.primary,
                        decoration: InputDecoration(
                          labelText: "About",
                          prefixIcon: const Icon(Icons.info_outline_rounded, color: AppColor.primary),
                          filled: true,
                          fillColor: AppColor.inputFill,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: AppColor.primary, width: 1.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                /// ─── Save Button ────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: Obx(() => Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        colors: [AppColor.primary, AppColor.second],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColor.primary.withValues(alpha: 0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: controller.isSaving.value ? null : controller.updateProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: controller.isSaving.value
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                            )
                          : const Text(
                              "Save Changes",
                              style: TextStyle(
                                color: AppColor.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  )),
                ),

                const SizedBox(height: 20),

                /// ─── Phone Card ─────────────────────────────
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColor.cardBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColor.dividerLight),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColor.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.phone_rounded, color: AppColor.primary, size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.phoneNumber,
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              "Phone number cannot be changed",
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColor.blueGrey.withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          );
        }),
      ),
    );
  }
}
