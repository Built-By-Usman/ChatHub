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
      // Soft modern background
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColor.primary.withOpacity(.05), AppColor.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Obx(() {
            if (controller.isLoading.value) {
              return Center(
                child: CircularProgressIndicator(color: AppColor.primary),
              );
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        "Setup Profile",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColor.primary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColor.primary.withOpacity(.2),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Obx(() {
                          if (controller.imageFile.value != null) {
                            return CircleAvatar(
                              radius: 65,
                              backgroundColor: AppColor.second,
                              backgroundImage: FileImage(
                                controller.imageFile.value!,
                              ),
                            );
                          }

                          if (controller.currentProfileUrl.value.isNotEmpty) {
                            return CachedNetworkImage(
                              imageUrl: controller.currentProfileUrl.value,
                              imageBuilder: (context, imageProvider) =>
                                  CircleAvatar(
                                    radius: 65,
                                    backgroundColor: AppColor.second,
                                    backgroundImage: imageProvider,
                                  ),
                              placeholder: (context, url) => CircleAvatar(
                                radius: 65,
                                backgroundColor: AppColor.second,
                                child: Center(
                                  child: SizedBox(
                                    width: 32,
                                    height: 32,
                                    child: CircularProgressIndicator(
                                      color: AppColor.white,
                                      strokeWidth: 2.5,
                                    ),
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) =>
                                  CircleAvatar(
                                    radius: 65,
                                    backgroundColor: AppColor.second,
                                    child: Icon(
                                      Icons.person,
                                      size: 70,
                                      color: AppColor.white,
                                    ),
                                  ),
                              fadeInDuration: const Duration(milliseconds: 250),
                              fadeOutDuration: const Duration(
                                milliseconds: 200,
                              ),
                            );
                          }

                          return CircleAvatar(
                            radius: 65,
                            backgroundColor: AppColor.second,
                            child: Icon(
                              Icons.person,
                              size: 70,
                              color: AppColor.white,
                            ),
                          );
                        }),
                      ),
                      GestureDetector(
                        onTap: controller.pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColor.third,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Colors.black26, blurRadius: 6),
                            ],
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            size: 20,
                            color: AppColor.white,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 50),

                  /// Name Field
                  Obx(
                    () => TextField(
                      cursorColor: AppColor.primary,
                      controller: controller.currentName.value != ''
                          ? controller.nameController
                          : null,
                      decoration: InputDecoration(
                        hint: Text(
                          controller.currentName.value != ''
                              ? controller.currentName.value
                              : 'Your Name',
                          style: TextStyle(color: AppColor.primary),
                        ),
                        labelStyle: TextStyle(color: AppColor.primary),
                        filled: true,
                        fillColor: AppColor.white,
                        prefixIcon: Icon(Icons.person, color: AppColor.primary),

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),

                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: AppColor.primary,
                            width: 2,
                          ),
                        ),
                      ),
                      onChanged: (val) => controller.name.value = val,
                    ),
                  ),

                  const Spacer(),

                  /// Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 6,
                        backgroundColor: controller.name.value.isNotEmpty
                            ? AppColor.primary
                            : AppColor.grey600,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: controller.name.value.isNotEmpty
                          ? controller.saveProfile
                          : null,
                      child: const Text(
                        "Save Profile",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
