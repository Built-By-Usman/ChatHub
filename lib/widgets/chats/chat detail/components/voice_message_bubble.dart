import 'package:ChatHub/core/constant/app_color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ChatHub/controller/voice_player_controller.dart';

class VoiceMessageBubble extends StatelessWidget {
  final String url;
  final bool isSender;
  final Widget timestampWidget;   // ← naya parameter

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
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10), // bottom padding badha diya
      decoration: BoxDecoration(
        color: isSender ? const Color(0xFFDCF8C6) : const Color(0xFFEFEFEF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          Obx(() {
            final duration = controller.getDuration(url);
            final isCurrent = controller.currentUrl.value == url;
            final showPosition = isCurrent && controller.isPlaying.value;

            return Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    if (controller.isLoading.value) return;
                    if (isCurrent && controller.isPlaying.value) {
                      controller.pause();
                    } else {
                      controller.play(url);
                    }
                  },
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                    child: controller.isLoading.value && isCurrent
                        ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2.5,color: AppColor.primary,),
                    )
                        : Icon(
                      isCurrent && controller.isPlaying.value
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      size: 28,
                      color: isSender ? const Color(0xFF4CAF50) : Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 140,
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 4,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 0),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 0),
                    ),
                    child: Slider(
                      min: 0,
                      max: duration.inSeconds.toDouble() == 0 ? 1 : duration.inSeconds.toDouble(),
                      value: showPosition
                          ? controller.position.value.inSeconds.toDouble().clamp(0.0, duration.inSeconds.toDouble())
                          : 0.0,
                      onChanged: duration.inSeconds == 0
                          ? null
                          : (value) => controller.seek(Duration(seconds: value.toInt())),
                      activeColor: isSender ? const Color(0xFF81C784) : Colors.blueGrey[300],
                      inactiveColor: Colors.grey[300],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Text(
                //   showPosition ? formatDuration(controller.position.value) : formatDuration(duration),
                //   style: TextStyle(
                //     fontSize: 11,
                //     color: Colors.black.withOpacity(0.65),
                //   ),
                // ),
                Text(
                  duration == Duration.zero
                      ? (controller.isLoading.value && controller.currentUrl.value == url ? 'Loading...' : '00:00')
                      : (showPosition ? formatDuration(controller.position.value) : formatDuration(duration)),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.black.withOpacity(0.65),
                  ),
                ),
              ],
            );
          }),

          // Tick + time ab yahan andar
          Positioned(
            bottom: -3,
            right: 8,
            child: timestampWidget,
          ),
        ],
      ),
    );
  }
}