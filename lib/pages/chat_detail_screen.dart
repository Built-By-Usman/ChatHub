import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../model/message_model.dart';
import '../../widgets/chats/chat detail/components/message_chat.dart';
import '../../../widgets/emoji/custom_emoji.dart';
import '../../widgets/chats/message_input.dart';
import '../controller/chat_detail_controller.dart';
import '../core/constant/app_color.dart';
import '../core/functions/transfer_date.dart';

class ChatDetailScreen extends StatelessWidget {
  const ChatDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChatDetailScreenController());

    return Scaffold(
      backgroundColor: AppColor.scaffoldBg,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColor.primary.withValues(alpha: 0.04),
              AppColor.scaffoldBg,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              /// ─── Header ──────────────────────────────────
              _buildHeader(context, controller),

              /// ─── Messages ────────────────────────────────
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColor.primary,
                        strokeWidth: 2.5,
                      ),
                    );
                  }

                  if (controller.messages.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 56,
                            color: AppColor.blueGrey.withValues(alpha: 0.2),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Say hello! 👋",
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColor.blueGrey.withValues(alpha: 0.5),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: controller.scrollController,
                    reverse: true,
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                    cacheExtent: 500,
                    addRepaintBoundaries: true,
                    addAutomaticKeepAlives: true,
                    itemCount: controller.messages.length,
                    itemBuilder: (_, index) {
                      final msgIndex = controller.messages.length - 1 - index;
                      final msg = controller.messages[msgIndex];

                      // Date header logic
                      String? header;
                      if (msgIndex == 0) {
                        header = getDateHeader(msg.timestamp);
                      } else {
                        final prevMsg = controller.messages[msgIndex - 1];
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
                                margin: const EdgeInsets.symmetric(vertical: 16),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColor.cardBg,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: AppColor.dividerLight),
                                ),
                                child: Text(
                                  header,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColor.blueGrey.withValues(alpha: 0.7),
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

              /// ─── Input Area ──────────────────────────────
              _buildInputArea(controller),
            ],
          ),
        ),
      ),
    );
  }

  /// ─── Header Widget ─────────────────────────────────────
  Widget _buildHeader(BuildContext context, ChatDetailScreenController controller) {
    return Obx(() => Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        color: AppColor.cardBg,
        border: Border(
          bottom: BorderSide(color: AppColor.dividerLight, width: 1),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: controller.back,
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            color: AppColor.black,
          ),

          /// Avatar
          Hero(
            tag: 'avatar_${controller.getUserName()}',
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColor.primary.withValues(alpha: 0.1),
                  width: 2,
                ),
              ),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: AppColor.inputFill,
                child: ClipOval(
                  child: controller.hasPhoto()
                      ? Image.network(
                          controller.getUserPhoto()!,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.person_rounded, color: AppColor.blueGrey, size: 24),
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          /// Name + Status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.getUserName(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColor.black,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                StreamBuilder<String>(
                  stream: controller.otherUser.value?.userId == null
                      ? const Stream.empty()
                      : controller.userStatusStream(controller.otherUser.value!.userId),
                  builder: (_, snapshot) {
                    final status = snapshot.data ?? "Offline";
                    final isOnline = status == "Online";
                    return Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isOnline ? AppColor.third : AppColor.blueGrey.withValues(alpha: 0.3),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          status,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isOnline ? AppColor.third : AppColor.blueGrey.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert_rounded, size: 22),
            color: AppColor.blueGrey.withValues(alpha: 0.6),
          ),
        ],
      ),
    ));
  }

  /// ─── Input Area Widget ─────────────────────────────────
  Widget _buildInputArea(ChatDetailScreenController controller) {
    return Obx(() => Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      decoration: BoxDecoration(
        color: AppColor.cardBg,
        border: Border(
          top: BorderSide(color: AppColor.dividerLight, width: 1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              /// Input container
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: AppColor.inputFill,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: controller.isRecording.value
                      ? _buildRecordingIndicator(controller)
                      : const MessageInput(),
                ),
              ),

              const SizedBox(width: 8),

              /// Send / Mic Button
              GestureDetector(
                onTap: () {
                  if (controller.isSend.value && !controller.isRecording.value) {
                    controller.sendMessage();
                  }
                },
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
                behavior: HitTestBehavior.opaque,
                child: Obx(() {
                  final isRecording = controller.isRecording.value;
                  final isSendMode = controller.isSend.value;

                  return AnimatedScale(
                    scale: isRecording ? 1.15 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutBack,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: isRecording
                            ? null
                            : const LinearGradient(
                                colors: [AppColor.primary, AppColor.second],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                        color: isRecording ? Colors.red : null,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (isRecording ? Colors.red : AppColor.primary)
                                .withValues(alpha: 0.25),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        isSendMode
                            ? Icons.send_rounded
                            : (isRecording ? Icons.stop_rounded : Icons.mic_rounded),
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),

          /// Emoji Panel
          if (controller.isEmojiShow.value)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: CustomEmoji(onEmojiSelected: controller.onEmojiSelected),
            ),
        ],
      ),
    ));
  }

  /// Recording indicator
  Widget _buildRecordingIndicator(ChatDetailScreenController controller) {
    return SizedBox(
      height: 48,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            const _PulsingDot(),
            const SizedBox(width: 12),
            Text(
              controller.format(controller.recordDuration.value),
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const Spacer(),
            Text(
              "Recording...",
              style: TextStyle(
                color: AppColor.blueGrey.withValues(alpha: 0.5),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Pulsing red dot for recording
class _PulsingDot extends StatefulWidget {
  const _PulsingDot();

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) => Opacity(
        opacity: 0.3 + (_controller.value * 0.7),
        child: Container(
          width: 10,
          height: 10,
          decoration: const BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
