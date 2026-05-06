import 'package:flutter/material.dart';
import '../../../../core/constant/app_color.dart';

class CustomContactItem extends StatelessWidget {
  final String phoneNumber;
  final String? about;
  final String? photoUrl;
  final VoidCallback? onTap;

  const CustomContactItem({
    super.key,
    required this.phoneNumber,
    this.about,
    this.photoUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Material(
          color: AppColor.cardBg,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            splashColor: AppColor.primary.withValues(alpha: 0.04),
            highlightColor: AppColor.primary.withValues(alpha: 0.02),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColor.primary.withValues(alpha: 0.1),
                        width: 2,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 26,
                      backgroundColor: AppColor.inputFill,
                      backgroundImage: photoUrl != null && photoUrl!.isNotEmpty
                          ? NetworkImage(photoUrl!)
                          : null,
                      child: photoUrl == null || photoUrl!.isEmpty
                          ? const Icon(Icons.person_rounded, size: 26, color: AppColor.blueGrey)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          phoneNumber,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColor.black,
                          ),
                        ),
                        if (about != null && about!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            about!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColor.blueGrey.withValues(alpha: 0.6),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppColor.blueGrey.withValues(alpha: 0.3),
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