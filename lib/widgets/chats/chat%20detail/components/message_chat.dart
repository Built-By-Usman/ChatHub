import 'package:flutter/material.dart';
import 'package:ChatHub/core/constant/app_color.dart';
import 'package:ChatHub/core/constant/app_size.dart';
import 'package:ChatHub/core/functions/transfer_date.dart';
import 'package:ChatHub/model/message_model.dart';
import 'package:ChatHub/widgets/chats/chat%20detail/components/voice_message_bubble.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:get/get.dart';
import 'package:ChatHub/controller/voice_player_controller.dart';
import '../../../../controller/media_controller.dart';

class MessageChat extends StatelessWidget {
  final MessageModel messageModel;
  final bool isSender;

  const MessageChat({
    super.key,
    required this.messageModel,
    required this.isSender,
  });

  @override
  Widget build(BuildContext context) {
    final timestamp = transferTimeAMPM(messageModel.timestamp);
    final screenWidth = AppSize.screenWidth ?? MediaQuery.of(context).size.width;
    final minBubbleWidth = screenWidth * 0.20;

    // Common timestamp + seen ticks widget
    Widget timestampWidget(bool isMedia) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            timestamp,
            style: TextStyle(
              fontSize: 10,
              color: isMedia ? Colors.white.withOpacity(0.9) : AppColor.blueGrey.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
          if (isSender) ...[
            const SizedBox(width: 4),
            Icon(
              messageModel.isSeen ? Icons.done_all : Icons.done_all,
              size: 14,
              color: messageModel.isSeen ? Colors.blue : Colors.grey.shade400,
            ),
          ],
        ],
      );
    }

    return RepaintBoundary(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(isSender ? (10 * (1 - value)) : (-10 * (1 - value)), 0),
              child: child,
            ),
          );
        },
        child: _buildBubble(context, screenWidth, minBubbleWidth, timestampWidget),
      ),
    );
  }

  Widget _buildBubble(BuildContext context, double screenWidth, double minBubbleWidth, Widget Function(bool) timestampWidget) {
    // ────────────────────────────────────────────────
    //               IMAGE / VIDEO MESSAGE
    // ────────────────────────────────────────────────
    if (messageModel.type == MessageType.image || messageModel.type == MessageType.video) {
      final isVideo = messageModel.type == MessageType.video;

      return Align(
        alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          constraints: BoxConstraints(
            maxWidth: screenWidth * 0.72,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    if (isVideo) {
                      Get.to(() => VideoPlayerScreen(url: messageModel.mediaUrl!));
                    } else {
                      Get.to(() => FullScreenImage(url: messageModel.mediaUrl!));
                    }
                  },
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: isVideo
                        ? Container(
                            color: Colors.black87,
                            child: const Center(
                              child: Icon(
                                Icons.play_circle_fill_rounded,
                                color: Colors.white,
                                size: 64,
                              ),
                            ),
                          )
                        : Image.network(
                            messageModel.mediaUrl!,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: Colors.grey.shade200,
                                child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                              );
                            },
                          ),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: timestampWidget(true),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // ────────────────────────────────────────────────
    //               VOICE MESSAGE
    // ────────────────────────────────────────────────
    if (messageModel.type == MessageType.voice) {
      final voiceController = Get.find<VoicePlayerController>();

      return Align(
        alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          constraints: BoxConstraints(
            maxWidth: screenWidth * 0.75,
          ),
          child: VisibilityDetector(
            key: ValueKey('voice_${messageModel.mediaUrl}'),
            onVisibilityChanged: (VisibilityInfo info) {
              if (info.visibleFraction > 0.4) {
                voiceController.preloadDuration(messageModel.mediaUrl!);
              }
            },
            child: VoiceMessageBubble(
              url: messageModel.mediaUrl!,
              isSender: isSender,
              timestampWidget: timestampWidget(false),
            ),
          ),
        ),
      );
    }

    // ────────────────────────────────────────────────
    //               TEXT MESSAGE
    // ────────────────────────────────────────────────
    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        constraints: BoxConstraints(
          minWidth: minBubbleWidth,
          maxWidth: screenWidth * 0.75,
        ),
        decoration: BoxDecoration(
          gradient: isSender 
            ? LinearGradient(
                colors: [AppColor.primary, AppColor.second],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
          color: isSender ? null : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(22),
            topRight: const Radius.circular(22),
            bottomLeft: Radius.circular(isSender ? 22 : 4),
            bottomRight: Radius.circular(isSender ? 4 : 22),
          ),
          boxShadow: [
            BoxShadow(
              color: (isSender ? AppColor.primary : Colors.black).withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                messageModel.content ?? "",
                style: TextStyle(
                  fontSize: 15.5,
                  height: 1.45,
                  color: isSender ? Colors.white : AppColor.black.withOpacity(0.9),
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 6),
              timestampWidget(false),
            ],
          ),
        ),
      ),
    );
  }
}
