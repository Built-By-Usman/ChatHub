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
    final screenWidth = AppSize.screenWidth ?? MediaQuery
        .of(context)
        .size
        .width;
    final minBubbleWidth = screenWidth * 0.30;

    // Common timestamp + seen ticks widget (used for all types)
    Widget timestampWidget(bool isMedia) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            timestamp,
            style: TextStyle(
              fontSize: 10,
              color: isMedia?Colors.white.withOpacity(0.9):Colors.black.withOpacity(0.55),
            ),
          ),
          if (isSender) ...[
            const SizedBox(width: 4),
            Icon(
              messageModel.isSeen ? Icons.done_all : Icons.done_all,
              size: 14,
              color: messageModel.isSeen ? Colors.blue[700] : Colors.grey[600],
            ),
          ],
        ],
      );
    }

    if (messageModel.type == MessageType.image || messageModel.type == MessageType.video) {
      final isVideo = messageModel.type == MessageType.video;

      return Align(
        alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: minBubbleWidth,
            maxWidth: screenWidth * 0.72,
          ),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  // Media content
                  GestureDetector(
                    onTap: () {
                      if (isVideo) {
                        Get.to(() => VideoPlayerScreen(url: messageModel.mediaUrl!));
                      } else {
                        Get.to(() => FullScreenImage(url: messageModel.mediaUrl!));
                      }
                    },
                    child: isVideo
                        ? Container(
                      height: 240,
                      width: double.infinity,
                      color: Colors.black87,
                      child: const Center(
                        child: Icon(
                          Icons.play_circle_fill_rounded,
                          color: Colors.white70,
                          size: 90,
                        ),
                      ),
                    )
                        : Image.network(
                      messageModel.mediaUrl!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 240,
                          color: Colors.grey[200],
                          child: const Center(child: CircularProgressIndicator()),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 240,
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image, size: 80, color: Colors.grey),
                      ),
                    ),
                  ),

                  // Sender's green border + tail effect
                  if (isSender)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFFDCF8C6), // WhatsApp sender green
                            width: 6,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),

                  // Tail (triangular pointer) - only for sender
                  if (isSender)
                    Positioned(
                      bottom: 0,
                      right: -8,
                      child: CustomPaint(
                        size: const Size(16, 16),
                        painter: _BubbleTailPainter(),
                      ),
                    ),

                  // Timestamp + ticks (bottom-right)
                  Positioned(
                    bottom: 8,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.45),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: timestampWidget(true),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // ────────────────────────────────────────────────
    //               VOICE MESSAGE (already has it)
    // ────────────────────────────────────────────────
    if (messageModel.type == MessageType.voice) {
      final voiceController = Get.find<VoicePlayerController>();

      return Align(
        alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: minBubbleWidth,
            maxWidth: screenWidth * 0.75,
          ),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
        ),
      );
    }

    // ────────────────────────────────────────────────
    //               TEXT MESSAGE (already has it)
    // ────────────────────────────────────────────────
    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: minBubbleWidth,
          maxWidth: screenWidth * 0.75,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isSender ? AppColor.green10 : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 28),
                child: Text(
                  messageModel.content ?? "",
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.3,
                  ),
                ),
              ),
              Positioned(
                bottom: 6,
                right: 10,
                child: timestampWidget(false),
              ),
            ],
          ),
        ),
      ),
    );
  }


}

class _BubbleTailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFDCF8C6) // same green as border
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}