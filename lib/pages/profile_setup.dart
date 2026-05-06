import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/profile_setup_controller.dart';
import '../core/constant/app_color.dart';

class ProfileSetup extends StatelessWidget {
  ProfileSetup({super.key});

  final controller = Get.put(ProfileSetupController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.scaffoldBg,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColor.primary.withValues(alpha: 0.06),
              AppColor.scaffoldBg,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(color: AppColor.primary, strokeWidth: 2.5),
              );
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 24),

                  /// ─── Header ────────────────────────────
                  Text(
                    "Setup Profile",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColor.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Add your photo and name to get started",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),

                  const SizedBox(height: 40),

                  /// ─── Avatar ────────────────────────────
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              AppColor.primary.withValues(alpha: 0.15),
                              AppColor.third.withValues(alpha: 0.1),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColor.primary.withValues(alpha: 0.12),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Obx(() {
                          if (controller.imageFile.value != null) {
                            return CircleAvatar(
                              radius: 65,
                              backgroundImage: FileImage(controller.imageFile.value!),
                            );
                          }
                          if (controller.currentProfileUrl.value.isNotEmpty) {
                            return CachedNetworkImage(
                              imageUrl: controller.currentProfileUrl.value,
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
                            );
                          }
                          return const CircleAvatar(
                            radius: 65,
                            backgroundColor: AppColor.inputFill,
                            child: Icon(Icons.person_rounded, size: 56, color: AppColor.blueGrey),
                          );
                        }),
                      ),
                      GestureDetector(
                        onTap: controller.pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColor.primary, AppColor.third],
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
                          child: const Icon(Icons.camera_alt_rounded, size: 20, color: Colors.white),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 48),

                  /// ─── Name Field ────────────────────────
                  Obx(() => TextField(
                    cursorColor: AppColor.primary,
                    controller: controller.currentName.value != ''
                        ? controller.nameController
                        : null,
                    decoration: InputDecoration(
                      hintText: controller.currentName.value != ''
                          ? controller.currentName.value
                          : 'Enter your name',
                      prefixIcon: const Icon(Icons.person_rounded, color: AppColor.primary),
                      filled: true,
                      fillColor: AppColor.cardBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: AppColor.dividerLight),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: AppColor.dividerLight),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColor.primary, width: 1.5),
                      ),
                    ),
                    onChanged: (val) => controller.name.value = val,
                  )),

                  const Spacer(),

                  /// ─── Save Button ──────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: Obx(() => Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: controller.name.value.isNotEmpty
                            ? const LinearGradient(
                                colors: [AppColor.primary, AppColor.second],
                              )
                            : null,
                        color: controller.name.value.isNotEmpty ? null : AppColor.inputFill,
                        boxShadow: controller.name.value.isNotEmpty
                            ? [
                                BoxShadow(
                                  color: AppColor.primary.withValues(alpha: 0.25),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ]
                            : null,
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: controller.name.value.isNotEmpty
                            ? controller.saveProfile
                            : null,
                        child: Text(
                          "Save Profile",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: controller.name.value.isNotEmpty
                                ? Colors.white
                                : AppColor.blueGrey,
                          ),
                        ),
                      ),
                    )),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
