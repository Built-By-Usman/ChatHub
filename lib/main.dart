import 'package:ChatHub/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'core/constant/app_color.dart';
import 'core/constant/app_route.dart';
import 'core/constant/app_size.dart';
import 'core/constant/app_string.dart';
import 'core/functions/presence_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Status bar style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  ));

  if (FirebaseAuth.instance.currentUser != null) {
    await PresenceService().init();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    AppSize().init(context);
    return GetMaterialApp(
      title: AppString.appName,
      debugShowCheckedModeBanner: false,

      // ─── Page Transitions ─────────────────────────────
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 250),

      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        primaryColor: AppColor.primary,
        fontFamily: 'Helvetica',
        splashFactory: InkSparkle.splashFactory,

        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColor.primary,
          primary: AppColor.primary,
          secondary: AppColor.second,
          tertiary: AppColor.third,
          surface: AppColor.scaffoldBg,
        ),

        scaffoldBackgroundColor: AppColor.scaffoldBg,

        // ─── AppBar ───────────────────────────────────────
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColor.black,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColor.black,
            fontFamily: 'Helvetica',
            letterSpacing: -0.3,
          ),
          iconTheme: IconThemeData(color: AppColor.black, size: 22),
        ),

        // ─── Cards ────────────────────────────────────────
        cardTheme: CardThemeData(
          color: AppColor.cardBg,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),

        // ─── FAB ──────────────────────────────────────────
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: AppColor.primary,
          foregroundColor: AppColor.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),

        // ─── Elevated Buttons ─────────────────────────────
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.primary,
            foregroundColor: AppColor.white,
            elevation: 0,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              fontFamily: 'Helvetica',
            ),
          ),
        ),

        // ─── Input Fields ─────────────────────────────────
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColor.inputFill,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColor.primary, width: 1.5),
          ),
          hintStyle: TextStyle(
            color: AppColor.blueGrey.withValues(alpha: 0.5),
            fontSize: 15,
          ),
          labelStyle: const TextStyle(
            color: AppColor.primary,
            fontWeight: FontWeight.w500,
          ),
        ),

        // ─── Divider ─────────────────────────────────────
        dividerTheme: const DividerThemeData(
          color: AppColor.dividerLight,
          thickness: 1,
          space: 0,
        ),

        // ─── Typography ──────────────────────────────────
        textTheme: TextTheme(
          headlineLarge: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: AppColor.black,
            letterSpacing: -1.0,
          ),
          headlineMedium: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: AppColor.black,
            letterSpacing: -0.5,
          ),
          titleLarge: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColor.black,
          ),
          titleMedium: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColor.black,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: AppColor.black.withValues(alpha: 0.9),
            height: 1.5,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: AppColor.black.withValues(alpha: 0.65),
            height: 1.4,
          ),
          labelSmall: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColor.black.withValues(alpha: 0.45),
          ),
        ),
      ),
      getPages: routes,
      initialRoute: AppRoute.splash,
    );
  }
}
