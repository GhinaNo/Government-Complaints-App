part of 'register_bloc.dart';

abstract class RegisterEvent {}

class RegisterSubmitted extends RegisterEvent {
  final RegisterRequest request;

  RegisterSubmitted({required this.request});
}