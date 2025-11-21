import 'package:bloc/bloc.dart';

import '../../../data/datasources/auth_remote_data_source.dart';
import '../../../data/models/register_request.dart';
import '../../../data/models/register_response.dart';

part 'register_event.dart';
part 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final AuthRemoteDataSource remoteDataSource;

  RegisterBloc({required this.remoteDataSource}) : super(RegisterInitial()) {
    on<RegisterSubmitted>(_onRegisterSubmitted);
  }

  Future<void> _onRegisterSubmitted(
      RegisterSubmitted event,
      Emitter<RegisterState> emit,
      ) async {
    emit(RegisterLoading());

    try {
      final response = await remoteDataSource.register(event.request);
      emit(RegisterSuccess(response: response));
    } catch (e) {
      emit(RegisterFailure(error: e.toString()));
    }
  }
}