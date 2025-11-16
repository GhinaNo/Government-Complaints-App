class RegisterModel {
  final String name;
  final String email;
  final String phoneNumber;
  final String password;
  final String passwordConfirmation;

  RegisterModel({
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.password,
    required this.passwordConfirmation,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
      'password': password,
      'password_confirmation': passwordConfirmation,
    };
  }
}