import 'package:ChatHub/pages/status_viwer_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/status_screen_controller.dart';
import '../core/constant/app_color.dart';
import '../core/functions/transfer_date.dart';
import '../model/status_model.dart';
import '../widgets/spacer/spacer.dart';
import 'package:image_picker/image_picker.dart';

class StatusScreen extends StatelessWidget {
  const StatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(StatusController());

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColor.primary.withOpacity(.05), AppColor.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator(color: AppColor.primary));
          }

          return ListView(
            children: [
              const VerticalSpacer(1),

              // My Status
              GestureDetector(
                onTap: () async {
                  final picker = ImagePicker();
                  final file = await picker.pickMedia();
                  if (file != null) {
                    await controller.addStatus(media: file);
                  }
                },
                child: controller.myStatuses.isEmpty
                    ? const OurStatusPlaceholder()
                    : OurStatus(statuses: controller.myStatuses),
              ),

              const Padding(
                padding: EdgeInsets.only(left: 13, bottom: 7, top: 7),
                child: Text(
                  "Recent updates",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),

              // Other users' statuses
              if (controller.friendsStatuses.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text("No recent updates", style: TextStyle(color: Colors.grey)),
                  ),
                )
              else
                ...controller.friendsStatuses.entries.map((entry) {
                  final userId = entry.key;
                  final data = entry.value;

                  return OtherStatusGroup(
                    userId: userId,
                    statuses: data['statuses'] as List<StatusModel>,
                    name: data['name'] as String,
                    photoUrl: data['photoUrl'] as String?,
                  );
                }),

              const Divider(color: Colors.grey, height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock, size: 14, color: AppColor.blueGrey),
                  const HorizontalSpacer(0.5),
                  Text.rich(
                    TextSpan(
                      text: "Your status updates are ",
                      style: TextStyle(
                        color: AppColor.blueGrey,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      children: [
                        TextSpan(
                          text: "end-to-end encrypted",
                          recognizer: TapGestureRecognizer()..onTap = () {},
                          style: const TextStyle(
                            color: AppColor.second,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        }),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const SizedBox(height: 16),
          FloatingActionButton(
            elevation: 6,
            onPressed: () async {
              final picker = ImagePicker();
              final file = await picker.pickMedia();
              if (file != null) {
                await Get.find<StatusController>().addStatus(media: file);
              }
            },
            child: const Icon(Icons.camera_alt_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

// Placeholder when no status exists
class OurStatusPlaceholder extends StatelessWidget {
  const OurStatusPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 27,
            backgroundColor: AppColor.white,
            child: const Icon(Icons.person, size: 40, color: Colors.grey),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: CircleAvatar(
              radius: 13,
              backgroundColor: AppColor.white,
              child: CircleAvatar(
                radius: 10,
                backgroundColor: AppColor.second,
                child: const Icon(Icons.add, size: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      title: const Text(
        "My Status",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: const Text(
        "Tap to add status update",
        style: TextStyle(fontSize: 13, color: Colors.grey),
      ),
    );
  }
}

// My status (when exists)
class OurStatus extends StatelessWidget {
  final List<StatusModel> statuses;
  const OurStatus({required this.statuses, super.key});

  @override
  Widget build(BuildContext context) {
    if (statuses.isEmpty) return const SizedBox.shrink();

    final latest = statuses.first;

    Widget avatarContent() {
      if (latest.mediaUrl == null || latest.mediaUrl!.isEmpty) {
        return const Icon(Icons.person, size: 40, color: Colors.grey);
      }

      if (latest.type == 'video') {
        return const Icon(Icons.videocam, size: 40, color: Colors.grey);
      }

      return ClipOval(
        child: Image.network(
          latest.mediaUrl!,
          fit: BoxFit.cover,
          width: 54,
          height: 54,
          errorBuilder: (context, error, stackTrace) => const Icon(
            Icons.broken_image,
            size: 40,
            color: Colors.grey,
          ),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const CircularProgressIndicator(color: AppColor.primary);
          },
        ),
      );
    }

    return ListTile(
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 27,
            backgroundColor: Colors.white,
            child: avatarContent(),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: CircleAvatar(
              radius: 13,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 10,
                backgroundColor: AppColor.second,
                child: const Icon(Icons.add, size: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      title: const Text("My Status", style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(
        "Added ${transferTimeAMPM(latest.createdAt.toDate())}",
        style: const TextStyle(fontSize: 13, color: Colors.grey),
      ),
      onTap: () {
        Get.to(() => StatusViewerScreen(
          statuses: statuses,
          initialIndex: 0,
        ));
      },
    );
  }
}

// Group of statuses from one user (now with real name & photo)
class OtherStatusGroup extends StatelessWidget {
  final String userId;
  final List<StatusModel> statuses;
  final String name;
  final String? photoUrl;

  const OtherStatusGroup({
    required this.userId,
    required this.statuses,
    required this.name,
    this.photoUrl,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (statuses.isEmpty) return const SizedBox.shrink();

    final latest = statuses.first;

    Widget avatarContent() {
      if (latest.mediaUrl == null || latest.mediaUrl!.isEmpty) {
        return const Icon(Icons.person, size: 36, color: Colors.grey);
      }

      if (latest.type == 'video') {
        return const Icon(Icons.videocam, size: 36, color: Colors.grey);
      }

      return ClipOval(
        child: Image.network(
          latest.mediaUrl!,
          fit: BoxFit.cover,
          width: 52,
          height: 52,
          errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 36, color: Colors.grey),
          loadingBuilder: (context, child, loading) {
            if (loading == null) return child;
            return const CircularProgressIndicator(color: AppColor.primary);
          },
        ),
      );
    }

    return ListTile(
      leading: CircleAvatar(
        radius: 26,
        backgroundColor: Colors.white,
        backgroundImage: photoUrl != null ? NetworkImage(photoUrl!) : null,
        child: photoUrl == null ? avatarContent() : null,
      ),
      title: Text(
        name,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        "Updated ${transferTimeAMPM(latest.createdAt.toDate())}",
        style: const TextStyle(fontSize: 13, color: Colors.grey),
      ),
      onTap: () {
        Get.to(() => StatusViewerScreen(
          statuses: statuses,
          initialIndex: 0,
        ));
      },
    );
  }
}