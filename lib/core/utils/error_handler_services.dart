import 'package:complaint_app/core/utils/toast_services.dart';

import '../utils/app_messages.dart';
import 'package:flutter/material.dart';

class ErrorHandlerService {
  static String handleApiError(dynamic error) {
    if (error is String) {
      return _parseArabicErrorMessage(error);
    }

    if (error is FormatException) {
      return AppMessages.serverError;
    } else if (error.toString().contains('TimeoutException')) {
      return AppMessages.timeoutError;
    } else if (error.toString().contains('SocketException')) {
      return AppMessages.networkError;
    }

    return AppMessages.unknownError;
  }

  static String _parseArabicErrorMessage(String error) {
    final errorLower = error.toLowerCase();

    if (errorLower.contains('network') || errorLower.contains('internet') || errorLower.contains('connection')) {
      return AppMessages.networkError;
    } else if (errorLower.contains('unauthorized') || errorLower.contains('token')) {
      return AppMessages.unauthorized;
    } else if (errorLower.contains('server')) {
      return AppMessages.serverError;
    } else if (errorLower.contains('email') && errorLower.contains('already')) {
      return AppMessages.emailAlreadyExists;
    } else if (errorLower.contains('invalid') && errorLower.contains('code')) {
      return AppMessages.invalidVerificationCode;
    } else if (errorLower.contains('invalid') && (errorLower.contains('email') || errorLower.contains('password'))) {
      return AppMessages.invalidCredentials;
    } else if (errorLower.contains('user') && errorLower.contains('not found')) {
      return AppMessages.userNotFound;
    } else if (errorLower.contains('verification') && errorLower.contains('expired')) {
      return AppMessages.verificationCodeExpired;
    }

    if (error.length < 80 && _isArabicFriendly(error)) {
      return error;
    }

    return AppMessages.unknownError;
  }

  static bool _isArabicFriendly(String message) {
    final technicalTerms = [
      'exception', 'error', 'failed', 'null', 'undefined',
      'sql', 'database', 'query', 'syntax'
    ];

    return !technicalTerms.any((term) => message.toLowerCase().contains(term));
  }

  static void showApiError(BuildContext context, dynamic error) {
    final errorMessage = handleApiError(error);
    ToastService.showError(context, errorMessage);
  }

  static void showSuccessMessage(BuildContext context, String message) {
    ToastService.showSuccess(context, message);
  }

  static void showWarningMessage(BuildContext context, String message) {
    ToastService.showWarning(context, message);
  }
}