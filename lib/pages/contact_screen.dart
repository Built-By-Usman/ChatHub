import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/contact_controller.dart';
import '../core/constant/app_color.dart';
import '../core/constant/app_route.dart';
import '../widgets/contact/components/custom_contact_item.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ContactScreenController());

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColor.primary.withOpacity(.05), AppColor.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: AppColor.primary),
                      onPressed: () => Get.back(),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        cursorColor: AppColor.primary,
                        controller: controller.searchController,
                        decoration: InputDecoration(
                          hintText: 'Phone No with country code',
                          hintStyle: TextStyle(color: AppColor.primary),
                          prefixIcon: Icon(Icons.search, color: AppColor.primary),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: AppColor.primary, width: 2),
                          ),
                        ),
                        keyboardType: TextInputType.phone,
                        onChanged: (val) => controller.phoneNumber.value = val,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return Center(
                      child: CircularProgressIndicator(color: AppColor.primary),
                    );
                  }

                  if (controller.userList.isEmpty) {
                    return const Center(child: Text("No user found"));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: controller.userList.length,
                    itemBuilder: (context, index) {
                      final user = controller.userList[index];
                      return CustomContactItem(
                        phoneNumber: user.phoneNumber,
                        photoUrl: user.photoUrl,
                        about: user.about,
                        onTap: () {
                          controller.createConversation(index);
                        },
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}