import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constant/app_color.dart';
import '../../controller/chat_detail_controller.dart';

class MessageInput extends StatelessWidget {
  const MessageInput({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ChatDetailScreenController>();

    return TextFormField(
      controller: controller.messageController,
      focusNode: controller.focusNode,
      minLines: 1,
      maxLines: 5,
      onChanged: controller.changeInput,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColor.white,
        hintText: "Type a message",
        hintStyle: const TextStyle(fontSize: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide.none,
        ),
        prefixIcon: IconButton(
          icon: const Icon(Icons.emoji_emotions),
          onPressed: controller.toggleEmoji,
        ),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Camera icon now opens gallery for image/video
            IconButton(
              icon: const Icon(Icons.camera_alt),
              onPressed: () {
                controller.pickAndSendMedia();
              },
            ),
          ],
        ),
      ),
    );
  }
}