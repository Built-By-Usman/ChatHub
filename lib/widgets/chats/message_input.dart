import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constant/app_color.dart';
import '../../controller/chat_detail_controller.dart';

class MessageInput extends StatelessWidget {
  const MessageInput({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ChatDetailScreenController>();

    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.emoji_emotions_outlined, size: 22),
          color: AppColor.blueGrey.withValues(alpha: 0.6),
          onPressed: controller.toggleEmoji,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        ),
        Expanded(
          child: TextFormField(
            controller: controller.messageController,
            focusNode: controller.focusNode,
            minLines: 1,
            maxLines: 5,
            onChanged: controller.changeInput,
            style: const TextStyle(fontSize: 15, color: AppColor.black),
            decoration: InputDecoration(
              hintText: "Type a message...",
              hintStyle: TextStyle(
                fontSize: 15,
                color: AppColor.blueGrey.withValues(alpha: 0.4),
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              fillColor: Colors.transparent,
              filled: false,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.attach_file_rounded, size: 22),
          color: AppColor.blueGrey.withValues(alpha: 0.6),
          onPressed: () {},
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        ),
        IconButton(
          icon: const Icon(Icons.camera_alt_outlined, size: 22),
          color: AppColor.blueGrey.withValues(alpha: 0.6),
          onPressed: () => controller.pickAndSendMedia(),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        ),
      ],
    );
  }
}