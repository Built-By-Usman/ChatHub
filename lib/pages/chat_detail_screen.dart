import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../model/message_model.dart';
import '../../widgets/chats/chat detail/components/message_chat.dart';
import '../../../widgets/emoji/custom_emoji.dart';
import '../../widgets/chats/message_input.dart';
import '../../../widgets/spacer/spacer.dart';
import '../controller/chat_detail_controller.dart';
import '../core/constant/app_color.dart';
import '../core/functions/transfer_date.dart';

class ChatDetailScreen extends StatelessWidget {
  const ChatDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChatDetailScreenController());

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
              /// -------- Header ----------
              Obx(() {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: controller.back,
                        child: Row(
                          children: [
                            Icon(
                              Icons.arrow_back,
                              size: 24,
                              color: AppColor.black,
                            ),

                            const SizedBox(width: 8),

                            CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.grey.shade300,
                              child: ClipOval(
                                child: controller.hasPhoto()
                                    ? Image.network(
                                        controller.getUserPhoto()!,
                                        width: 40,
                                        height: 40,
                                        fit: BoxFit.cover,
                                      )
                                    : const Icon(Icons.person),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              controller.getUserName(),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColor.black,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            StreamBuilder<String>(
                              stream: controller.otherUser.value?.userId == null
                                  ? const Stream.empty()
                                  : controller.userStatusStream(
                                      controller.otherUser.value!.userId,
                                    ),
                              builder: (_, snapshot) => Text(
                                snapshot.data ?? "",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColor.black.withOpacity(.6),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),

              /// -------- Chat Messages ----------
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return Center(
                      child: CircularProgressIndicator(color: AppColor.primary),
                    );
                  }

                  return ListView.builder(
                    controller: controller.scrollController,
                    reverse: true,
                    // latest messages at bottom
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 6,
                    ),
                    itemCount: controller.messages.length,
                    itemBuilder: (_, index) {
                      // In reversed list, index 0 = latest message
                      final msgIndex = controller.messages.length - 1 - index;
                      final msg = controller.messages[msgIndex];

                      // Determine if we need a date header
                      String? header;
                      if (msgIndex == 0) {
                        // First message in chronological order
                        header = getDateHeader(msg.timestamp);
                      } else {
                        final prevMsg =
                            controller.messages[msgIndex -
                                1]; // previous in chronological order
                        if (!isSameDay(prevMsg.timestamp, msg.timestamp)) {
                          header = getDateHeader(msg.timestamp);
                        }
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (header != null)
                            Center(
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  header,
                                  style: const TextStyle(
                                    color: Colors.black54,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          MessageChat(
                            isSender: msg.senderId == controller.myId,
                            messageModel: msg,
                          ),
                        ],
                      );
                    },
                  );
                }),
              ),

              /// -------- Input + Emoji ----------
              Obx(() {
                return Column(
                  children: [
                    Row(
                      children: [
                        /// INPUT AREA
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(
                              left: 2,
                              right: 2,
                              bottom: 10,
                            ),
                            child: controller.isRecording.value
                                ? Container(
                                    height: 50,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColor.white,
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    child: Row(
                                      children: [
                                        /// EMOJI ICON (same as MessageInput prefix)
                                        IconButton(
                                          icon: const Icon(
                                            Icons.emoji_emotions,
                                          ),
                                          onPressed: controller.toggleEmoji,
                                        ),

                                        /// RECORDING CONTENT
                                        const Icon(
                                          Icons.mic,
                                          color: Colors.red,
                                        ),
                                        const SizedBox(width: 8),

                                        Text(
                                          controller.format(
                                            controller.recordDuration.value,
                                          ),
                                          style: const TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),

                                        const Spacer(),

                                        /// CAMERA ICON (same as suffix)
                                        if (!controller.isSend.value)
                                          const Icon(Icons.camera_alt),
                                      ],
                                    ),
                                  )
                                : const MessageInput(),
                          ),
                        ),

                        /// SEND / MIC BUTTON
                        /// SEND / MIC BUTTON
                        Container(
                          margin: const EdgeInsets.only(left: 3, right: 3, bottom: 10),
                          child: GestureDetector(
                            // ─── Normal tap: send text message ───
                            onTap: () {
                              if (controller.isSend.value && !controller.isRecording.value) {
                                controller.sendMessage();
                              }
                            },

                            // ─── Long press: voice recording ───
                            onLongPressStart: (details) {
                              if (!controller.isSend.value && !controller.isRecording.value) {
                                controller.startRecording();
                              }
                            },
                            onLongPressEnd: (details) {
                              if (controller.isRecording.value) {
                                controller.stopRecording();
                              }
                            },
                            onLongPressMoveUpdate: (details) {
                              // Optional future: slide-to-cancel logic
                            },

                            behavior: HitTestBehavior.opaque,

                            child: Obx(() {
                              final isRecording = controller.isRecording.value;
                              final isSendMode = controller.isSend.value;

                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOut,
                                transform: Matrix4.translationValues(0, isRecording ? -20 : 0, 0),
                                child: AnimatedScale(
                                  scale: isRecording ? 1.4 : 1.0,
                                  duration: const Duration(milliseconds: 280),
                                  curve: Curves.easeOutBack,
                                  child: CircleAvatar(
                                    radius: 28,
                                    backgroundColor: isRecording
                                        ? Colors.red
                                        : (isSendMode ? AppColor.primary : AppColor.second),
                                    child: Icon(
                                      isSendMode
                                          ? Icons.send_rounded
                                          : isRecording
                                          ? Icons.stop_rounded
                                          : Icons.mic_rounded,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),                      ],
                    ),

                    /// EMOJI PANEL
                    controller.isEmojiShow.value
                        ? CustomEmoji(
                            onEmojiSelected: controller.onEmojiSelected,
                          )
                        : const SizedBox(),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
