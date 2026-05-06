import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/constant/app_color.dart';
import '../../../model/chat_model.dart';

class CustomChatCard extends StatelessWidget {
  final ChatModel chatModel;
  final VoidCallback onTap;
  final Widget? profileWidget;

  const CustomChatCard({
    super.key,
    required this.chatModel,
    required this.onTap,
    this.profileWidget,
  });

  @override
  Widget build(BuildContext context) {
    final bool isUnread = chatModel.isSeen != true &&
        chatModel.conversation.senderId != FirebaseAuth.instance.currentUser!.uid;

    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        child: Material(
          color: AppColor.cardBg,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            splashColor: AppColor.primary.withValues(alpha: 0.04),
            highlightColor: AppColor.primary.withValues(alpha: 0.02),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: isUnread
                    ? Border.all(color: AppColor.third.withValues(alpha: 0.3), width: 1.5)
                    : null,
              ),
              child: Row(
                children: [
                  /// ─── Avatar ──────────────────────────────
                  Hero(
                    tag: 'avatar_${chatModel.name}',
                    child: profileWidget ??
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColor.inputFill,
                            border: Border.all(
                              color: AppColor.dividerLight,
                              width: 1.5,
                            ),
                          ),
                          child: const Icon(Icons.person_rounded, size: 28, color: AppColor.blueGrey),
                        ),
                  ),

                  const SizedBox(width: 14),

                  /// ─── Name + Message ──────────────────────
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                chatModel.name,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: isUnread ? FontWeight.w800 : FontWeight.w600,
                                  color: AppColor.black,
                                ),
                              ),
                            ),
                            if (chatModel.lastMessage.isNotEmpty)
                              Text(
                                TimeOfDay.fromDateTime(chatModel.lastMessageTime).format(context),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isUnread ? FontWeight.w700 : FontWeight.w500,
                                  color: isUnread ? AppColor.third : AppColor.blueGrey.withValues(alpha: 0.6),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            // Sent message tick
                            if (chatModel.lastMessage.isNotEmpty &&
                                chatModel.conversation.senderId == FirebaseAuth.instance.currentUser!.uid)
                              Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: Icon(
                                  Icons.done_all_rounded,
                                  size: 16,
                                  color: chatModel.isSeen
                                      ? const Color(0xFF4FC3F7)
                                      : AppColor.blueGrey.withValues(alpha: 0.4),
                                ),
                              ),
                            Expanded(
                              child: Text(
                                chatModel.lastMessage,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                  color: isUnread
                                      ? AppColor.black.withValues(alpha: 0.8)
                                      : AppColor.blueGrey.withValues(alpha: 0.7),
                                  fontWeight: isUnread ? FontWeight.w600 : FontWeight.w400,
                                  fontSize: 13.5,
                                ),
                              ),
                            ),
                            // Unread dot
                            if (isUnread)
                              Container(
                                margin: const EdgeInsets.only(left: 10),
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: AppColor.third,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}