import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../config/theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.directions_car,
                size: 80,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(height: 24),
              const Text(
                'Connexion Chauffeur',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 48),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Mot de passe',
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 24),
              Obx(() => authController.errorMessage.value.isNotEmpty 
                  ? Text(authController.errorMessage.value, style: const TextStyle(color: Colors.red))
                  : const SizedBox.shrink()
              ),
              const SizedBox(height: 16),
              Obx(() => ElevatedButton(
                onPressed: authController.isLoading.value ? null : () async {
                  final success = await authController.signIn(
                    _emailController.text.trim(), 
                    _passwordController.text
                  );
                  if (success) {
                    Get.offAllNamed('/home');
                  }
                },
                child: authController.isLoading.value 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('SE CONNECTER'),
              )),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Get.toNamed('/register'),
                child: const Text('Devenir Chauffeur'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
