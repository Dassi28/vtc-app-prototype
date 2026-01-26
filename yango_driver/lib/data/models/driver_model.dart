enum VehicleType { moto, standard, comfort, van }

class DriverModel {
  final String id;
  final String? fullName;
  final String? email;
  final String? phone;
  final VehicleType vehicleType;
  final String vehicleBrand;
  final String vehicleModel;
  final String licensePlate;
  final bool isAvailable;
  final bool isVerified;
  final double rating;
  final double totalEarnings;
  final double? currentLatitude;
  final double? currentLongitude;

  DriverModel({
    required this.id,
    this.fullName,
    this.email,
    this.phone,
    required this.vehicleType,
    required this.vehicleBrand,
    required this.vehicleModel,
    required this.licensePlate,
    this.isAvailable = false,
    this.isVerified = false,
    this.rating = 5.0,
    this.totalEarnings = 0.0,
    this.currentLatitude,
    this.currentLongitude,
  });

  factory DriverModel.fromJson(Map<String, dynamic> json, {Map<String, dynamic>? userJson}) {
    // Combine data from 'drivers' table and 'users' table
    return DriverModel(
      id: json['id'],
      fullName: userJson?['full_name'],
      email: userJson?['email'],
      phone: userJson?['phone'],
      vehicleType: VehicleType.values.firstWhere(
        (e) => e.name == json['vehicle_type'],
        orElse: () => VehicleType.standard,
      ),
      vehicleBrand: json['vehicle_brand'] ?? '',
      vehicleModel: json['vehicle_model'] ?? '',
      licensePlate: json['license_plate'] ?? '',
      isAvailable: json['is_available'] ?? false,
      isVerified: json['is_verified'] ?? false,
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      totalEarnings: (json['total_earnings'] as num?)?.toDouble() ?? 0.0,
      currentLatitude: (json['current_latitude'] as num?)?.toDouble(),
      currentLongitude: (json['current_longitude'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicle_type': vehicleType.name,
      'vehicle_brand': vehicleBrand,
      'vehicle_model': vehicleModel,
      'license_plate': licensePlate,
      'is_available': isAvailable,
      'current_latitude': currentLatitude,
      'current_longitude': currentLongitude,
    };
  }
}
