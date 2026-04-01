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
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColor.primary.withOpacity(0.08),
              AppColor.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColor.primary,
                ),
              );
            }

            final user = controller.currentUser.value;

            if (user == null) {
              return const Center(
                child: Text("Profile not found"),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 20,
              ),
              child: Column(
                children: [

                  const SizedBox(height: 20),

                  /// 🔵 PROFILE IMAGE
                  SizedBox(
                    width: 130,
                    height: 130,
                    child: Stack(
                      children: [

                        /// PROFILE IMAGE
                        ClipOval(
                          child: user.photoUrl != null
                              ? Image.network(
                            user.photoUrl!,
                            width: 130,
                            height: 130,
                            fit: BoxFit.cover,

                            /// 👇 shows loader
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;

                              return Container(
                                color: Colors.grey.shade200,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: AppColor.primary,
                                  ),
                                ),
                              );
                            },

                            /// 👇 fallback if error
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey.shade200,
                                child: const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          )
                              : Container(
                            color: Colors.grey.shade200,
                            child: const Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.grey,
                            ),
                          ),
                        ),

                        /// CAMERA ICON
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColor.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  /// 🧾 CARD SECTION
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        )
                      ],
                    ),
                    child: Column(
                      children: [

                        /// NAME
                        TextField(
                          controller: controller.nameController,
                          textCapitalization:
                          TextCapitalization.words,
                          decoration: InputDecoration(
                            labelText: "Full Name",
                            prefixIcon: Icon(
                              Icons.person,
                              color: AppColor.primary,
                            ),
                            border: OutlineInputBorder(
                              borderRadius:
                              BorderRadius.circular(14),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                              BorderRadius.circular(14),
                              borderSide: BorderSide(
                                color: AppColor.primary,
                                width: 2,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        /// ABOUT
                        TextField(
                          controller: controller.aboutController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            labelText: "About",
                            alignLabelWithHint: true,
                            prefixIcon: Icon(
                              Icons.info_outline,
                              color: AppColor.primary,
                            ),
                            border: OutlineInputBorder(
                              borderRadius:
                              BorderRadius.circular(14),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                              BorderRadius.circular(14),
                              borderSide: BorderSide(
                                color: AppColor.primary,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// SAVE BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: controller.isSaving.value
                          ? null
                          : controller.updateProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(16),
                        ),
                        elevation: 4,
                      ),
                      child: controller.isSaving.value
                          ? const SizedBox(
                        height: 22,
                        width: 22,
                        child:
                        CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                          : Text(
                        "Save Changes",
                        style: TextStyle(
                          color: AppColor.white,
                          fontSize: 16,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// PHONE CARD
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                      BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.phone,
                          color: AppColor.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.phoneNumber,
                                style: const TextStyle(
                                  fontWeight:
                                  FontWeight.w600,
                                ),
                              ),
                              const Text(
                                "Phone number (cannot be changed)",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}