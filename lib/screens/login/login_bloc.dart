import 'package:earnfit/services/repository/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository authRepository;

  LoginBloc({required this.authRepository}) : super(const LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<TogglePasswordVisibility>(_onTogglePasswordVisibility);
  }

  Future<void> _onLoginSubmitted(
      LoginSubmitted event, Emitter<LoginState> emit) async {
    emit(LoginLoading());
    try {
      await authRepository.login(event.username, event.password);
      // Check if the token is available in the API service
      final token = AuthRepository().apiService.getToken(); // Replace with your actual method to get the token
      if (token != null) {

        await authRepository.getConfigData();

        // Navigate to the dashboard or perform other actions
        emit(LoginSuccess());
      } else {
        // Handle the case where the token is null
        emit(const LoginFailure(error: 'Token not found'));
      }
    } catch (error) {
      emit(LoginFailure(error: error.toString()));
    }

  }

  void _onTogglePasswordVisibility(
      TogglePasswordVisibility event, Emitter<LoginState> emit) {
    if (state is LoginInitial) {
      final currentState = state as LoginInitial;
      emit(LoginInitial(isPasswordVisible: !currentState.isPasswordVisible));
    }
  }
}
