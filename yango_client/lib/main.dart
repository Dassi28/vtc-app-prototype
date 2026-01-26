import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/supabase_config.dart';
import 'config/theme.dart';
import 'data/services/auth_service.dart';
import 'data/services/ride_service.dart';
import 'data/services/location_service.dart';
import 'controllers/auth_controller.dart';
import 'controllers/ride_controller.dart';
import 'views/splash_screen.dart';
import 'views/onboarding/onboarding_screen.dart';
import 'views/auth/login_screen.dart';
import 'views/home/home_screen.dart';
import 'views/ride/ride_tracking_screen.dart';
import 'views/ride/ride_history_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  // Inject services
  Get.put(AuthService());
  Get.put(RideService());
  Get.put(LocationService());

  // Inject controllers
  Get.put(AuthController());
  Get.put(RideController());

  runApp(const YangoClientApp());
}

class YangoClientApp extends StatelessWidget {
  const YangoClientApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Yango Clone',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      getPages: [
        GetPage(
          name: '/',
          page: () => const SplashScreen(),
        ),
        GetPage(
          name: '/onboarding',
          page: () => const OnboardingScreen(),
        ),
        GetPage(
          name: '/login',
          page: () => const LoginScreen(),
        ),
        GetPage(
          name: '/home',
          page: () => const HomeScreen(),
        ),
        GetPage(
          name: '/ride-tracking',
          page: () => const RideTrackingScreen(),
        ),
        GetPage(
          name: '/ride-history',
          page: () => const RideHistoryScreen(),
        ),
      ],
    );
  }
}
