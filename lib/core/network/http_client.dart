import 'dart:convert';
import 'package:http/http.dart' as client;
import '../constants/api_constants.dart';
import '../utils/error_handler_services.dart';
import '../utils/logger.dart';
import 'package:http/http.dart' as http;

import '../utils/app_messages.dart';

class HttpClient {
  Future<Map<String, dynamic>> post({
    required String endpoint,
    required Map<String, dynamic> data,
  }) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');

      Logger.api('POST', endpoint);
      Logger.debug('URL: $url');
      Logger.debug('Data: $data');

      final response = await client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(data),
      ).timeout(const Duration(seconds: ApiConstants.timeoutSeconds));

      Logger.debug('Status: ${response.statusCode}');
      Logger.debug('Response: ${response.body}');

      return _handleResponse(response);
    } catch (e) {
      Logger.error('Request failed', error: e);

      final arabicError = ErrorHandlerService.handleApiError(e);
      throw Exception(arabicError);
    }
  }

  Future<Map<String, dynamic>> get({
    required String endpoint,
    Map<String, String>? headers,
  }) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');

      Logger.api('GET', endpoint);
      Logger.debug('URL: $url');

      final response = await client.get(
        url,
        headers: headers ?? {
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: ApiConstants.timeoutSeconds));

      Logger.debug('Status: ${response.statusCode}');
      Logger.debug('Response: ${response.body}');

      return _handleResponse(response);
    } catch (e) {
      Logger.error('GET Request failed', error: e);

      final arabicError = ErrorHandlerService.handleApiError(e);
      throw Exception(arabicError);
    }
  }

  Future<bool> ping() async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/');
      final response = await client.get(url).timeout(
        const Duration(seconds: 10),
      );

      Logger.debug('Ping status: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      Logger.error('Ping failed', error: e);
      return false;
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    final responseBody = response.body;

    if (responseBody.isEmpty) {
      throw Exception(AppMessages.serverError);
    }

    try {
      final jsonResponse = json.decode(responseBody);

      if (statusCode >= 200 && statusCode < 300) {
        return jsonResponse;
      } else {
        final errorMessage = _extractArabicErrorMessage(jsonResponse, statusCode);
        throw Exception(errorMessage);
      }
    } catch (e) {
      Logger.error('JSON parse failed', error: e);
      throw Exception(AppMessages.serverError);
    }
  }

  String _extractArabicErrorMessage(Map<String, dynamic> jsonResponse, int statusCode) {
    final rawMessage = jsonResponse['message'] ??
        jsonResponse['error'] ??
        jsonResponse['errors']?.toString() ??
        '';

    return _translateErrorMessage(rawMessage.toString(), statusCode);
  }

  String _translateErrorMessage(String message, int statusCode) {
    final messageLower = message.toLowerCase();

    if (messageLower.contains('the email has already been taken')) {
      return AppMessages.emailAlreadyExists;
    } else if (messageLower.contains('invalid verification code') ||
        messageLower.contains('wrong code')) {
      return AppMessages.invalidVerificationCode;
    } else if (messageLower.contains('these credentials do not match our records')) {
      return AppMessages.invalidCredentials;
    } else if (messageLower.contains('unauthenticated') ||
        messageLower.contains('token')) {
      return AppMessages.unauthorized;
    } else if (messageLower.contains('server error') ||
        messageLower.contains('internal server')) {
      return AppMessages.serverError;
    } else if (statusCode == 404) {
      return 'لم يتم العثور على الصفحة المطلوبة';
    } else if (statusCode == 500) {
      return AppMessages.serverError;
    } else if (statusCode == 401) {
      return AppMessages.unauthorized;
    } else if (statusCode == 403) {
      return 'ليس لديك صلاحية للوصول إلى هذا المورد';
    } else if (statusCode == 422) {
      return 'بيانات غير صحيحة. يرجى مراجعة المدخلات';
    }

    if (message.isNotEmpty && message.length < 100 && _isUserFriendly(message)) {
      return message;
    }

    return 'حدث خطأ (رمز: $statusCode)';
  }

  bool _isUserFriendly(String message) {
    final technicalTerms = [
      'exception', 'error', 'failed', 'null', 'undefined',
      'sql', 'database', 'query', 'syntax', 'stack trace'
    ];

    return !technicalTerms.any((term) => message.toLowerCase().contains(term));
  }
}