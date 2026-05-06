import 'package:ChatHub/pages/status_viwer_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/status_screen_controller.dart';
import '../core/constant/app_color.dart';
import '../core/functions/transfer_date.dart';
import '../model/status_model.dart';
import 'package:image_picker/image_picker.dart';

class StatusScreen extends StatelessWidget {
  const StatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final StatusController controller = Get.put(StatusController());

    return Scaffold(
      backgroundColor: AppColor.scaffoldBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ─── Header ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Text(
                "Status",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColor.primary,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, bottom: 16),
              child: Text(
                "Share moments with friends",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),

            /// ─── Content ─────────────────────────────────
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColor.primary, strokeWidth: 2.5),
                  );
                }

                return ListView(
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  padding: const EdgeInsets.only(bottom: 100),
                  children: [
                    /// ─── My Status ────────────────────────
                    _buildMyStatus(context, controller),

                    const SizedBox(height: 8),

                    /// ─── Section Label ────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                      child: Text(
                        "RECENT UPDATES",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColor.blueGrey.withValues(alpha: 0.5),
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),

                    /// ─── Friends' Statuses ───────────────
                    if (controller.friendsStatuses.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(40),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.update_rounded,
                                size: 48,
                                color: AppColor.blueGrey.withValues(alpha: 0.2),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "No recent updates",
                                style: TextStyle(
                                  color: AppColor.blueGrey.withValues(alpha: 0.4),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      for (var entry in controller.friendsStatuses.entries)
                        _buildFriendStatusTile(context, controller, entry),

                    /// ─── Encryption Notice ───────────────
                    const SizedBox(height: 24),
                    const Divider(indent: 20, endIndent: 20),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.lock_rounded, size: 13, color: AppColor.blueGrey.withValues(alpha: 0.4)),
                        const SizedBox(width: 4),
                        Text.rich(
                          TextSpan(
                            text: "Your status updates are ",
                            style: TextStyle(
                              color: AppColor.blueGrey.withValues(alpha: 0.5),
                              fontSize: 12,
                            ),
                            children: [
                              TextSpan(
                                text: "end-to-end encrypted",
                                recognizer: TapGestureRecognizer()..onTap = () {},
                                style: TextStyle(
                                  color: AppColor.primary.withValues(alpha: 0.7),
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
          ],
        ),
      ),

      /// ─── FAB ───────────────────────────────────────────
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final ImagePicker picker = ImagePicker();
          final XFile? selectedFile = await picker.pickMedia();
          if (selectedFile != null) {
            await Get.find<StatusController>().addStatus(media: selectedFile);
          }
        },
        child: const Icon(Icons.camera_alt_rounded),
      ),
    );
  }

  /// ─── My Status Tile ────────────────────────────────────
  Widget _buildMyStatus(BuildContext context, StatusController controller) {
    return GestureDetector(
      onTap: () async {
        if (controller.myStatuses.isNotEmpty) {
          Get.to(() => StatusViewerScreen(
            statuses: controller.myStatuses,
            initialIndex: 0,
          ));
          return;
        }
        final ImagePicker picker = ImagePicker();
        final XFile? selectedFile = await picker.pickMedia();
        if (selectedFile != null) {
          await controller.addStatus(media: selectedFile);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Material(
          color: AppColor.cardBg,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                /// Avatar with gradient ring
                Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: controller.myStatuses.isNotEmpty
                            ? const LinearGradient(
                                colors: [AppColor.primary, AppColor.third],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        border: controller.myStatuses.isEmpty
                            ? Border.all(color: AppColor.dividerLight, width: 2)
                            : null,
                      ),
                      child: CircleAvatar(
                        radius: 27,
                        backgroundColor: AppColor.inputFill,
                        child: _buildMyStatusAvatar(controller),
                      ),
                    ),
                    if (controller.myStatuses.isEmpty)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: AppColor.third,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.add, size: 14, color: Colors.white),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "My Status",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: AppColor.black,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        controller.myStatuses.isEmpty
                            ? "Tap to add status update"
                            : "Added ${transferTimeAMPM(controller.myStatuses.first.createdAt.toDate())}",
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColor.blueGrey.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMyStatusAvatar(StatusController controller) {
    if (controller.myStatuses.isEmpty) {
      return const Icon(Icons.person_rounded, size: 32, color: AppColor.blueGrey);
    }
    final latest = controller.myStatuses.first;
    if (latest.mediaUrl == null || latest.mediaUrl!.isEmpty) {
      return const Icon(Icons.person_rounded, size: 32, color: AppColor.blueGrey);
    }
    if (latest.type == 'video') {
      return const Icon(Icons.videocam_rounded, size: 32, color: AppColor.blueGrey);
    }
    return ClipOval(
      child: Image.network(
        latest.mediaUrl!,
        fit: BoxFit.cover,
        width: 54,
        height: 54,
        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 32, color: AppColor.blueGrey),
      ),
    );
  }

  /// ─── Friend Status Tile ────────────────────────────────
  Widget _buildFriendStatusTile(BuildContext context, StatusController controller, MapEntry entry) {
    List<StatusModel> statuses = entry.value['statuses'] as List<StatusModel>;
    String friendName = entry.value['name'] as String;
    String? friendPhotoUrl = entry.value['photoUrl'] as String?;

    if (statuses.isEmpty) return const SizedBox.shrink();

    StatusModel latestStatus = statuses.first;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: AppColor.cardBg,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          splashColor: AppColor.primary.withValues(alpha: 0.04),
          onTap: () {
            Get.to(() => StatusViewerScreen(
              statuses: statuses,
              initialIndex: 0,
            ));
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [AppColor.primary, AppColor.third],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColor.inputFill,
                    backgroundImage: friendPhotoUrl != null ? NetworkImage(friendPhotoUrl) : null,
                    child: friendPhotoUrl == null
                        ? _buildFriendAvatarFallback(latestStatus)
                        : null,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        friendName,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        "Updated ${transferTimeAMPM(latestStatus.createdAt.toDate())}",
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColor.blueGrey.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFriendAvatarFallback(StatusModel latestStatus) {
    if (latestStatus.mediaUrl == null || latestStatus.mediaUrl!.isEmpty) {
      return const Icon(Icons.person_rounded, size: 28, color: AppColor.blueGrey);
    }
    if (latestStatus.type == 'video') {
      return const Icon(Icons.videocam_rounded, size: 28, color: AppColor.blueGrey);
    }
    return ClipOval(
      child: Image.network(
        latestStatus.mediaUrl!,
        fit: BoxFit.cover,
        width: 48,
        height: 48,
        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 28, color: AppColor.blueGrey),
      ),
    );
  }
}