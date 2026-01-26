import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/supabase_config.dart';
import 'config/theme.dart';
import 'data/services/auth_service.dart';
import 'data/services/driver_service.dart';
import 'data/services/ride_service.dart';
import 'controllers/auth_controller.dart';
import 'controllers/driver_controller.dart';
import 'controllers/ride_controller.dart';
import 'views/splash_screen.dart';
import 'views/auth/login_screen.dart';
import 'views/auth/register_screen.dart';
import 'views/home/home_screen.dart';
import 'views/ride/active_ride_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  // Inject Services
  Get.put(AuthService());
  Get.put(DriverService());
  Get.put(RideService());

  // Inject Controllers
  // Note: DriverController and RideController are put lazily or inside pages, 
  // but for global availability putting Auth here is key.
  Get.put(AuthController());

  runApp(const YangoDriverApp());
}

class YangoDriverApp extends StatelessWidget {
  const YangoDriverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Yango Driver',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Supports dark mode
      initialRoute: '/',
      getPages: [
        GetPage(
          name: '/',
          page: () => const SplashScreen(),
        ),
        GetPage(
          name: '/login',
          page: () => const LoginScreen(),
        ),
        GetPage(
          name: '/register',
          page: () => const RegisterScreen(),
        ),
        GetPage(
          name: '/home',
          page: () => const HomeScreen(),
        ),
        GetPage(
          name: '/active-ride',
          page: () => const ActiveRideScreen(),
        ),
      ],
    );
  }
}
