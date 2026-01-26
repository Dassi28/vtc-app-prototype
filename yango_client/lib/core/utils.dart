import 'package:intl/intl.dart';

class AppUtils {
  static String formatCurrency(double amount) {
    final format = NumberFormat.currency(locale: 'fr_CM', symbol: 'FCFA', decimalDigits: 0);
    return format.format(amount);
  }

  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
  
  static bool isValidPhone(String phone) {
    // Simple validation for Cameroon numbers (9 digits)
    return RegExp(r'^(6)(5|7|8|9)[0-9]{7}$').hasMatch(phone) || phone.length >= 9;
  }
}
