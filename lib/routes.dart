import 'package:ChatHub/pages/chat_detail_screen.dart';
import 'package:ChatHub/pages/contact_screen.dart';
import 'package:ChatHub/pages/home_screen.dart';
import 'package:ChatHub/pages/login_screen.dart';
import 'package:ChatHub/pages/onboard_screen.dart';
import 'package:ChatHub/pages/profile_setup.dart';
import 'package:ChatHub/pages/splash_screen.dart';
import 'package:get/get.dart';

import 'core/constant/app_route.dart';

List<GetPage<dynamic>>? routes = [
  GetPage(name: AppRoute.splash, page: ()=>SplashScreen()),
  GetPage(name: AppRoute.onboard, page: ()=>OnboardScreen()),
  GetPage(name: AppRoute.login, page: ()=>LoginScreen()),
  GetPage(name: AppRoute.home, page: ()=>HomeScreen()),
  GetPage(name: AppRoute.profileSetup, page: ()=>ProfileSetup()),
  GetPage(name: AppRoute.contact, page: ()=>ContactScreen()),
  GetPage(name: AppRoute.chatDetail, page: ()=>ChatDetailScreen()),

];