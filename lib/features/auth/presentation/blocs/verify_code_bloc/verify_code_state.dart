
import '../../../data/models/verify_code_response.dart';

abstract class VerificationState {}

class VerificationInitial extends VerificationState {}

class VerificationLoading extends VerificationState {}

class VerificationSuccess extends VerificationState {
  final VerificationResponse response;

  VerificationSuccess({required this.response});
}

class VerificationFailure extends VerificationState {
  final String error;

  VerificationFailure({required this.error});
}