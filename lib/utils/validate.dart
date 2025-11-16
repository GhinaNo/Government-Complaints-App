import 'package:flutter/material.dart';

class Validate {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Enter email';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Invalid email';
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty || value.length < 2) {
      return 'Enter valid name';
    }
    return null;
  }

  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Enter phone number';
    }

    final phoneRegex = RegExp(r'^[0-9]{10,15}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Enter a valid phone number (10-15 digits)';
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Enter password';
    }

    final hasUpperCase = RegExp(r'[A-Z]').hasMatch(value);
    final hasLowerCase = RegExp(r'[a-z]').hasMatch(value);
    final hasNumber = RegExp(r'[0-9]').hasMatch(value);
    final hasSpecialChar = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value);
    final hasMinLength = value.length >= 8;

    if (!hasMinLength) return 'Password must be at least 8 characters';
    if (!hasUpperCase) return 'Include at least one uppercase letter';
    if (!hasLowerCase) return 'Include at least one lowercase letter';
    if (!hasNumber) return 'Include at least one number';
    if (!hasSpecialChar) return 'Include at least one special character';

    return null;
  }

  static String? validateLoginPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Enter password';
    }
    return null;
  }

  static String? validateConfirm(
      String? value,
      TextEditingController passCtrl,
      ) {
    if (value != passCtrl.text) return 'Passwords do not match';
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