import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/constant/app_color.dart';
import '../model/status_model.dart';

class StatusViewerScreen extends StatefulWidget {
  final List<StatusModel> statuses;
  final int initialIndex;

  const StatusViewerScreen({
    super.key,
    required this.statuses,
    this.initialIndex = 0,
  });

  @override
  State<StatusViewerScreen> createState() => _StatusViewerScreenState();
}

class _StatusViewerScreenState extends State<StatusViewerScreen> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: (details) {
          final width = MediaQuery.of(context).size.width;
          if (details.globalPosition.dx < width / 2) {
            // Tap left → previous
            if (_currentIndex > 0) {
              _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
          } else {
            // Tap right → next
            if (_currentIndex < widget.statuses.length - 1) {
              _pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            } else {
              Get.back(); // Last status → close
            }
          }
        },
        child: PageView.builder(
          controller: _pageController,
          itemCount: widget.statuses.length,
          onPageChanged: (index) => setState(() => _currentIndex = index),
          itemBuilder: (context, index) {
            final status = widget.statuses[index];

            if (status.type == 'video') {
              return VideoStatusPlayer(url: status.mediaUrl!);
            } else {
              return ImageStatusViewer(url: status.mediaUrl!);
            }
          },
        ),
      ),
    );
  }
}

class ImageStatusViewer extends StatelessWidget {
  final String url;
  const ImageStatusViewer({required this.url, super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.contain,
        placeholder: (context, url) => const Center(child: CircularProgressIndicator(color: AppColor.primary)),
        errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.white),
      ),
    );
  }
}

class VideoStatusPlayer extends StatefulWidget {
  final String url;
  const VideoStatusPlayer({required this.url, super.key});

  @override
  _VideoStatusPlayerState createState() => _VideoStatusPlayerState();
}

class _VideoStatusPlayerState extends State<VideoStatusPlayer> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
        _controller.setLooping(true);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _controller.value.isInitialized
          ? AspectRatio(
        aspectRatio: _controller.value.aspectRatio,
        child: VideoPlayer(_controller),
      )
          : const CircularProgressIndicator(color: Colors.white),
    );
  }
}