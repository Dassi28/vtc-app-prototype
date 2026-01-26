import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/theme.dart';

class AvailabilityToggle extends StatelessWidget {
  final bool isAvailable;
  final Function(bool) onChanged;

  const AvailabilityToggle({
    super.key,
    required this.isAvailable,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!isAvailable),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 180,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isAvailable ? AppTheme.successColor : Colors.grey[800],
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
             BoxShadow(
               color: isAvailable ? AppTheme.successColor.withOpacity(0.4) : Colors.black26,
               blurRadius: 10,
               offset: const Offset(0, 4),
             )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isAvailable ? Icons.power_settings_new : Icons.power_off,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              isAvailable ? 'EN LIGNE' : 'HORS LIGNE',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
