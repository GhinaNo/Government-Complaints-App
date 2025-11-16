import 'dart:convert';
import 'package:complaint_app/models/register.dart';
import 'package:http/http.dart' as http;

class AuthRepository {
  static const String baseUrl = 'http://5.5.5.240:8000/api';

  Future<http.Response> register(RegisterModel request) async {
    try {
      final Map<String, dynamic> requestBody = {
        'name': request.name,
        'email': request.email,
        'phone_number': request.phoneNumber,
        'password': request.password,
        'password_confirmation': request.passwordConfirmation,
      };

      print('📦 Sending request: $requestBody');

      final response = await http.post(
        Uri.parse('$baseUrl/user/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      return response;
    } catch (e) {
      print('❌ Error: $e');
      throw Exception('Network error: $e');
    }
  }}