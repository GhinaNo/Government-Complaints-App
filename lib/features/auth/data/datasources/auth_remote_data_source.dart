import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/http_client.dart';
import '../../../../core/utils/logger.dart';
import '../models/register_request.dart';
import '../models/register_response.dart';
import '../models/verify_code_request.dart';
import '../models/verify_code_response.dart';

class AuthRemoteDataSource {
  final HttpClient httpClient;

  AuthRemoteDataSource({required this.httpClient});

  Future<RegisterResponse> register(RegisterRequest request) async {
    try {
      Logger.info('Starting registration');

      final response = await httpClient.post(
        endpoint: ApiEndpoints.register,
        data: request.toJson(),
      );

      Logger.info('Registration successful');
      return RegisterResponse.fromJson(response);
    } catch (e) {
      Logger.error('Registration failed', error: e);
      rethrow;
    }
  }


  Future<VerificationResponse> verifyCode(VerificationRequest request) async {
    try {
      Logger.info('Starting verification for: ${request.email}');

      final response = await httpClient.post(
        endpoint: ApiEndpoints.verifyCode,
        data: request.toJson(),
      );

      Logger.info('Verification successful for: ${request.email}');
      return VerificationResponse.fromJson(response);
    } catch (e) {
      Logger.error('Verification failed for: ${request.email}', error: e);
      rethrow;
    }
  }

}
