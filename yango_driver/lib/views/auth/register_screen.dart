import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/theme.dart';
import '../../controllers/auth_controller.dart';
import '../../data/models/driver_model.dart'; // For VehicleType enum

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Personal Info
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // Vehicle Info
  VehicleType _selectedVehicleType = VehicleType.standard;
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _plateController = TextEditingController();
  final _licenseController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Inscription Chauffeur')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Informations Personnelles', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nom complet', prefixIcon: Icon(Icons.person)),
                validator: (v) => v!.isEmpty ? 'Requis' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Téléphone', prefixIcon: Icon(Icons.phone)),
                keyboardType: TextInputType.phone,
                validator: (v) => v!.isEmpty ? 'Requis' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email)),
                keyboardType: TextInputType.emailAddress,
                validator: (v) => v!.isEmpty ? 'Requis' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Mot de passe', prefixIcon: Icon(Icons.lock)),
                obscureText: true,
                validator: (v) => v!.length < 6 ? 'Min 6 caractères' : null,
              ),
              
              const SizedBox(height: 32),
              const Text('Informations Véhicule', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<VehicleType>(
                value: _selectedVehicleType,
                decoration: const InputDecoration(labelText: 'Type de véhicule', prefixIcon: Icon(Icons.local_taxi)),
                items: VehicleType.values.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type.name.toUpperCase()));
                }).toList(),
                onChanged: (val) => setState(() => _selectedVehicleType = val!),
              ),
              const SizedBox(height: 12),
               Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _brandController,
                      decoration: const InputDecoration(labelText: 'Marque'),
                      validator: (v) => v!.isEmpty ? 'Requis' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _modelController,
                      decoration: const InputDecoration(labelText: 'Modèle'),
                      validator: (v) => v!.isEmpty ? 'Requis' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _plateController,
                decoration: const InputDecoration(labelText: 'Plaque d\'immatriculation', prefixIcon: Icon(Icons.confirmation_number)),
                 validator: (v) => v!.isEmpty ? 'Requis' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _licenseController,
                decoration: const InputDecoration(labelText: 'Numéro Permis', prefixIcon: Icon(Icons.card_membership)),
                 validator: (v) => v!.isEmpty ? 'Requis' : null,
              ),
              
              const SizedBox(height: 32),
              
              Obx(() => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: authController.isLoading.value ? null : () async {
                    if (_formKey.currentState!.validate()) {
                      final success = await authController.register(
                        email: _emailController.text,
                        password: _passwordController.text,
                        fullName: _nameController.text,
                        phone: _phoneController.text,
                        vehicleType: _selectedVehicleType,
                        vehicleBrand: _brandController.text,
                        vehicleModel: _modelController.text,
                        licensePlate: _plateController.text,
                        driverLicense: _licenseController.text,
                      );
                      
                      if (success) {
                        Get.offAllNamed('/home');
                      }
                    }
                  },
                  child: authController.isLoading.value 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('S\'INSCRIRE'),
                ),
              )),
              
              TextButton(
                 onPressed: () => Get.back(),
                 child: const Text('Déjà un compte ? Se connecter'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
