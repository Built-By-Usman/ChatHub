import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/chat_controller.dart';
import '../core/constant/app_color.dart';
import '../core/constant/app_string.dart';
import '../widgets/chats/custom_chat_card.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChatScreenController());
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppString.appName,
                      style: TextStyle(
                        color: AppColor.primary,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => controller.goToCameraScreen(),
                          icon: const Icon(Icons.camera_alt_rounded),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.search),
                        ),
                        SizedBox(width: 7),
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: InkWell(
                            onTap: () {
                              controller.goToContactScreen();
                            },
                            child: CircleAvatar(
                              backgroundColor: AppColor.primary,
                              radius: 12,
                              child: Icon(
                                Icons.add,
                                color: AppColor.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Obx(() {
                  if (controller.isLoading.value) {
                    return Expanded(
                      child: Center(
                        child: CircularProgressIndicator(color: AppColor.primary),
                      ),
                    );
                  }

                  return Expanded(
                    child: ListView.builder(
                      itemCount: controller.chats.length,
                      itemBuilder: (context, index) {
                        final chat = controller.chats[index];

                        return CustomChatCard(
                          chatModel: chat,
                          onTap: () => controller.goToDetailScreen(chat),
                          profileWidget: chat.profilePicture != null &&
                              chat.profilePicture!.isNotEmpty
                              ? CircleAvatar(
                            radius: 25,
                            backgroundImage: NetworkImage(chat.profilePicture!),
                          )
                              : null,
                        );                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
