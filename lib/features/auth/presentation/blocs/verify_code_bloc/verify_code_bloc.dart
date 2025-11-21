import 'package:bloc/bloc.dart';
import 'package:complaint_app/features/auth/presentation/blocs/verify_code_bloc/verify_code_event.dart';
import 'package:complaint_app/features/auth/presentation/blocs/verify_code_bloc/verify_code_state.dart';
import '../../../data/datasources/auth_remote_data_source.dart';

class VerificationBloc extends Bloc<VerificationEvent, VerificationState> {
  final AuthRemoteDataSource remoteDataSource;

  VerificationBloc({required this.remoteDataSource}) : super(VerificationInitial()) {
    on<VerificationSubmitted>(_onVerificationSubmitted);
  }

  Future<void> _onVerificationSubmitted(
      VerificationSubmitted event,
      Emitter<VerificationState> emit,
      ) async {
    emit(VerificationLoading());

    try {
      final response = await remoteDataSource.verifyCode(event.request);
      emit(VerificationSuccess(response: response));
    } catch (e) {
      emit(VerificationFailure(error: e.toString()));
    }
  }
}