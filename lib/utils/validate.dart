import 'package:flutter/material.dart';

class Validate {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'أدخل البريد الإلكتروني';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'بريد إلكتروني غير صحيح';
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty || value.length < 2) {
      return 'أدخل اسم صحيح';
    }
    return null;
  }

  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'أدخل رقم الهاتف';
    }

    final phoneRegex = RegExp(r'^[0-9]{10,15}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'أدخل رقم هاتف صحيح (10-15 رقم)';
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'أدخل كلمة المرور';
    }

    final hasUpperCase = RegExp(r'[A-Z]').hasMatch(value);
    final hasLowerCase = RegExp(r'[a-z]').hasMatch(value);
    final hasNumber = RegExp(r'[0-9]').hasMatch(value);
    final hasSpecialChar = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value);
    final hasMinLength = value.length >= 8;

    if (!hasMinLength) return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
    if (!hasUpperCase) return 'أضف حرف كبير واحد على الأقل';
    if (!hasLowerCase) return 'أضف حرف صغير واحد على الأقل';
    if (!hasNumber) return 'أضف رقم واحد على الأقل';
    if (!hasSpecialChar) return 'أضف رمز خاص واحد على الأقل';

    return null;
  }

  static String? validateLoginPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'أدخل كلمة المرور';
    }
    return null;
  }

  static String? validateConfirm(
      String? value,
      TextEditingController passCtrl,
      ) {
    if (value != passCtrl.text) return 'كلمات المرور غير متطابقة';
    return null;
  }

  static Map<String, bool> checkPasswordRequirements(String password) {
    return {
      '8_characters': password.length >= 8,
      'uppercase': RegExp(r'[A-Z]').hasMatch(password),
      'lowercase': RegExp(r'[a-z]').hasMatch(password),
      'number': RegExp(r'[0-9]').hasMatch(password),
      'special_char': RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password),
    };
  }

  static Color getPasswordStrengthColor(String password) {
    final requirements = checkPasswordRequirements(password);
    final metCount = requirements.values.where((met) => met).length;

    if (metCount == 5) return Colors.green;
    if (metCount >= 3) return Colors.orange;
    return Colors.red;
  }
}