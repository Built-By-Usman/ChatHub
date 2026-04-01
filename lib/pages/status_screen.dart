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
    // Initialize the controller using GetX
    final StatusController controller = Get.put(StatusController());

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

          // Show a loading spinner while data is being fetched
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppColor.primary),
            );
          }

          // Main scrollable content
          return ListView(
            children: [
              const VerticalSpacer(1),

              // ── My Status Section ──────────────────────────────────────

              // Tapping this opens the media picker to add a new status
              GestureDetector(
                onTap: () async {
                  // Open the media picker
                  final ImagePicker picker = ImagePicker();
                  final XFile? selectedFile = await picker.pickMedia();

                  // Only upload if user actually picked something
                  if (selectedFile != null) {
                    await controller.addStatus(media: selectedFile);
                  }
                },

                child: controller.myStatuses.isEmpty

                // ── No status yet: show placeholder ─────────────────────
                    ? ListTile(
                  leading: Stack(
                    children: [
                      // Grey person icon as default avatar
                      CircleAvatar(
                        radius: 27,
                        backgroundColor: AppColor.white,
                        child: const Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.grey,
                        ),
                      ),

                      // Green "+" button at bottom-right of avatar
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 13,
                          backgroundColor: AppColor.white,
                          child: CircleAvatar(
                            radius: 10,
                            backgroundColor: AppColor.second,
                            child: const Icon(
                              Icons.add,
                              size: 16,
                              color: Colors.white,
                            ),
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
                )

                    : ListTile(
                  leading: Stack(
                    children: [
                      // Show a preview of the latest status inside the avatar
                      CircleAvatar(
                        radius: 27,
                        backgroundColor: Colors.white,
                        child: () {
                          StatusModel latest = controller.myStatuses.first;

                          // No media URL — show default person icon
                          if (latest.mediaUrl == null || latest.mediaUrl!.isEmpty) {
                            return const Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.grey,
                            );
                          }

                          // Video status — show camera icon as preview
                          if (latest.type == 'video') {
                            return const Icon(
                              Icons.videocam,
                              size: 40,
                              color: Colors.grey,
                            );
                          }

                          // Image status — show the actual image
                          return ClipOval(
                            child: Image.network(
                              latest.mediaUrl!,
                              fit: BoxFit.cover,
                              width: 54,
                              height: 54,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.broken_image,
                                  size: 40,
                                  color: Colors.grey,
                                );
                              },
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const CircularProgressIndicator(
                                  color: AppColor.primary,
                                );
                              },
                            ),
                          );
                        }(),
                      ),

                      // Green "+" button at bottom-right of avatar
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 13,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 10,
                            backgroundColor: AppColor.second,
                            child: const Icon(
                              Icons.add,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  title: const Text(
                    "My Status",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "Added ${transferTimeAMPM(controller.myStatuses.first.createdAt.toDate())}",
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  onTap: () {
                    // Open status viewer to watch my statuses
                    Get.to(() => StatusViewerScreen(
                      statuses: controller.myStatuses,
                      initialIndex: 0,
                    ));
                  },
                ),
              ),

              // ── Recent Updates Label ───────────────────────────────────

              const Padding(
                padding: EdgeInsets.only(left: 13, bottom: 7, top: 7),
                child: Text(
                  "Recent updates",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // ── Friends' Statuses ──────────────────────────────────────

              // Show this message when no friends have any active statuses
              if (controller.friendsStatuses.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      "No recent updates",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
              // Loop through each friend and build a status tile for them
                for (var entry in controller.friendsStatuses.entries)
                      () {
                    // Extract this friend's data from the map
                    String userId = entry.key;
                    List<StatusModel> statuses = entry.value['statuses'] as List<StatusModel>;
                    String friendName = entry.value['name'] as String;
                    String? friendPhotoUrl = entry.value['photoUrl'] as String?;

                    // Don't show tile if this friend has no statuses
                    if (statuses.isEmpty) return const SizedBox.shrink();

                    // Use the most recently posted status as the preview
                    StatusModel latestStatus = statuses.first;

                    return ListTile(
                      leading: CircleAvatar(
                        radius: 26,
                        backgroundColor: Colors.white,

                        // Show friend's profile photo if available
                        backgroundImage: friendPhotoUrl != null
                            ? NetworkImage(friendPhotoUrl)
                            : null,

                        // If no profile photo, show the status media preview
                        child: friendPhotoUrl != null
                            ? null
                            : () {
                          // No media — show person icon
                          if (latestStatus.mediaUrl == null ||
                              latestStatus.mediaUrl!.isEmpty) {
                            return const Icon(
                              Icons.person,
                              size: 36,
                              color: Colors.grey,
                            );
                          }

                          // Video — show camera icon
                          if (latestStatus.type == 'video') {
                            return const Icon(
                              Icons.videocam,
                              size: 36,
                              color: Colors.grey,
                            );
                          }

                          // Image — show the actual image
                          return ClipOval(
                            child: Image.network(
                              latestStatus.mediaUrl!,
                              fit: BoxFit.cover,
                              width: 52,
                              height: 52,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.broken_image,
                                  size: 36,
                                  color: Colors.grey,
                                );
                              },
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const CircularProgressIndicator(
                                  color: AppColor.primary,
                                );
                              },
                            ),
                          );
                        }(),
                      ),
                      title: Text(
                        friendName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        "Updated ${transferTimeAMPM(latestStatus.createdAt.toDate())}",
                        style: const TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      onTap: () {
                        // Open the status viewer for this friend
                        Get.to(() => StatusViewerScreen(
                          statuses: statuses,
                          initialIndex: 0,
                        ));
                      },
                    );
                  }(),

              // ── Bottom Encryption Notice ───────────────────────────────

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

      // ── Floating Camera Button ───────────────────────────────────────────

      floatingActionButton: FloatingActionButton(
        elevation: 6,
        onPressed: () async {
          // Open media picker when camera button is tapped
          final ImagePicker picker = ImagePicker();
          final XFile? selectedFile = await picker.pickMedia();

          // Only upload if user actually picked something
          if (selectedFile != null) {
            await Get.find<StatusController>().addStatus(media: selectedFile);
          }
        },
        child: const Icon(Icons.camera_alt_rounded, color: Colors.white),
      ),
    );
  }
}