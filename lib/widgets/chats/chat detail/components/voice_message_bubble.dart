import 'package:ChatHub/core/constant/app_color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ChatHub/controller/voice_player_controller.dart';

class VoiceMessageBubble extends StatelessWidget {
  final String url;
  final bool isSender;
  final Widget timestampWidget;

  const VoiceMessageBubble({
    super.key,
    required this.url,
    required this.isSender,
    required this.timestampWidget,
  });

  String formatDuration(Duration d) {
    final minutes = d.inMinutes.toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<VoicePlayerController>();

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
      decoration: BoxDecoration(
        gradient: isSender
            ? const LinearGradient(
                colors: [AppColor.sentBubbleStart, AppColor.sentBubbleEnd],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isSender ? null : AppColor.receivedBubble,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(20),
          topRight: const Radius.circular(20),
          bottomLeft: Radius.circular(isSender ? 20 : 4),
          bottomRight: Radius.circular(isSender ? 4 : 20),
        ),
        border: isSender ? null : Border.all(color: AppColor.dividerLight, width: 1),
        boxShadow: [
          BoxShadow(
            color: (isSender ? AppColor.primary : Colors.black).withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Obx(() {
            final duration = controller.getDuration(url);
            final isCurrent = controller.currentUrl.value == url;
            final showPosition = isCurrent && controller.isPlaying.value;

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// Play/Pause Button
                GestureDetector(
                  onTap: () {
                    if (controller.isLoading.value) return;
                    if (isCurrent && controller.isPlaying.value) {
                      controller.pause();
                    } else {
                      controller.play(url);
                    }
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isSender
                          ? Colors.white.withValues(alpha: 0.2)
                          : AppColor.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: controller.isLoading.value && isCurrent
                        ? Padding(
                            padding: const EdgeInsets.all(10),
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: isSender ? Colors.white : AppColor.primary,
                            ),
                          )
                        : Icon(
                            isCurrent && controller.isPlaying.value
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            size: 24,
                            color: isSender ? Colors.white : AppColor.primary,
                          ),
                  ),
                ),
                const SizedBox(width: 8),

                /// Slider
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 3,
                      thumbShape: RoundSliderThumbShape(
                        enabledThumbRadius: showPosition ? 6 : 0,
                      ),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                      activeTrackColor: isSender ? Colors.white : AppColor.primary,
                      inactiveTrackColor: isSender
                          ? Colors.white.withValues(alpha: 0.25)
                          : AppColor.blueGrey.withValues(alpha: 0.2),
                      thumbColor: isSender ? Colors.white : AppColor.primary,
                    ),
                    child: Slider(
                      min: 0,
                      max: duration.inSeconds.toDouble() == 0
                          ? 1
                          : duration.inSeconds.toDouble(),
                      value: showPosition
                          ? controller.position.value.inSeconds
                              .toDouble()
                              .clamp(0.0, duration.inSeconds.toDouble())
                          : 0.0,
                      onChanged: duration.inSeconds == 0
                          ? null
                          : (value) => controller.seek(Duration(seconds: value.toInt())),
                    ),
                  ),
                ),
                const SizedBox(width: 4),

                /// Duration text
                Text(
                  duration == Duration.zero
                      ? (controller.isLoading.value && controller.currentUrl.value == url
                          ? '...'
                          : '00:00')
                      : (showPosition
                          ? formatDuration(controller.position.value)
                          : formatDuration(duration)),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isSender
                        ? Colors.white.withValues(alpha: 0.7)
                        : AppColor.blueGrey.withValues(alpha: 0.7),
                  ),
                ),
              ],
            );
          }),

          const SizedBox(height: 4),
          timestampWidget,
        ],
      ),
    );
  }
}