import 'package:complaint_app/models/register.dart';

abstract class AuthEvent {}

class RegisterEvent extends AuthEvent {
  final RegisterModel registerModel;
  RegisterEvent(this.registerModel);
}