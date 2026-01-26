import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/theme.dart';
import '../../../data/models/driver_model.dart';
import '../../../data/services/ride_service.dart';
import '../../../core/utils.dart';

class VehicleSelectorWidget extends StatelessWidget {
  final Rx<VehicleType> selectedType;
  final Function(VehicleType) onSelect;
  final RxDouble distance;

  const VehicleSelectorWidget({
    super.key,
    required this.selectedType,
    required this.onSelect,
    required this.distance,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Type de véhicule',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Obx(() => Row(
                children: VehicleType.values.map((type) {
                  final isSelected = selectedType.value == type;
                  final price = RideService.basePrices[type]! +
                      (RideService.pricePerKm[type]! * distance.value);

                  return GestureDetector(
                    onTap: () => onSelect(type),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primaryColor.withOpacity(0.1)
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.primaryColor
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            _getVehicleIcon(type),
                            size: 32,
                            color: isSelected
                                ? AppTheme.primaryColor
                                : Colors.grey[600],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _getVehicleName(type),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? AppTheme.primaryColor
                                  : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppUtils.formatCurrency(price),
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected
                                  ? AppTheme.primaryColor
                                  : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              )),
        ),
      ],
    );
  }

  IconData _getVehicleIcon(VehicleType type) {
    switch (type) {
      case VehicleType.moto:
        return Icons.two_wheeler;
      case VehicleType.standard:
        return Icons.directions_car;
      case VehicleType.comfort:
        return Icons.local_taxi;
      case VehicleType.van:
        return Icons.airport_shuttle;
    }
  }

  String _getVehicleName(VehicleType type) {
    switch (type) {
      case VehicleType.moto:
        return 'Moto';
      case VehicleType.standard:
        return 'Standard';
      case VehicleType.comfort:
        return 'Confort';
      case VehicleType.van:
        return 'Van';
    }
  }
}
