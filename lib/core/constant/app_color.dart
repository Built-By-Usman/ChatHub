import 'package:flutter/material.dart';

class AppColor {
  AppColor._();

  // ─── Brand Palette ──────────────────────────────────────
  static const Color primary = Color(0xff075e54);
  static const Color second = Color(0xff128C7E);
  static const Color third = Color(0xff25D366);
  static const Color white = Colors.white;

  // ─── Neutrals ───────────────────────────────────────────
  static const Color blueGrey = Colors.blueGrey;
  static Color blueGrey200 = Colors.blueGrey.shade200;
  static const Color grey = Color(0xff2D383E);
  static const Color grey1 = Color.fromARGB(255, 2, 0, 18);
  static Color grey600 = Colors.grey.shade600;
  static const Color black = Colors.black;

  // ─── Chat Bubbles ───────────────────────────────────────
  static const Color green10 = Color(0xffdcf8c6);
  static const Color sentBubbleStart = Color(0xff075e54);
  static const Color sentBubbleEnd = Color(0xff128C7E);
  static const Color receivedBubble = Colors.white;

  // ─── Semantic / UI ──────────────────────────────────────
  static const Color inputFill = Color(0xFFF5F6F8);
  static const Color cardBg = Colors.white;
  static const Color scaffoldBg = Color(0xFFF8F9FA);
  static const Color dividerLight = Color(0xFFEEEFF1);
  static const Color shimmerBase = Color(0xFFE8E8E8);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);

  // ─── Dark Mode (prepared for future) ────────────────────
  static const Color surfaceDark = Color(0xFF1A1A2E);
  static const Color cardDark = Color(0xFF232340);
  static const Color textDark = Color(0xFFE0E0E0);
  static const Color inputFillDark = Color(0xFF2A2A3D);
}