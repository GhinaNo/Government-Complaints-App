class RegisterResponse {
  final String message;
  final String expiresIn;
  final String status;

  RegisterResponse({
    required this.message,
    required this.expiresIn,
    required this.status,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return RegisterResponse(
      message: data['message'] ?? '',
      expiresIn: data['expires_in'] ?? '',
      status: json['status'] ?? '',
    );
  }
}