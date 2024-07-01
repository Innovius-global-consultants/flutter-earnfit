import 'package:bloc/bloc.dart';
import '../../services/repository/auth_repository.dart';
import 'register_event.dart';
import 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final AuthRepository authRepository;

  RegisterBloc({required this.authRepository})
      : super(const RegisterInitial()) {
    on<RegisterSubmitted>((event, emit) async {
      emit(RegisterLoading());
      try {
        // Call your repository method to register the user
        await authRepository.register(
          username: event.username,
          mobile_no: event.mobileNo,
          email: event.email,
          password: event.password,
        );
        emit(RegisterSuccess());
      } catch (e) {
        emit(RegisterFailure('Registration failed: $e'));
      }
    });

    on<TogglePasswordVisibility>((event, emit) {
      if (state is RegisterInitial) {
        final currentState = state as RegisterInitial;
        emit(currentState.copyWith(
            isPasswordVisible: !currentState.isPasswordVisible));
      }
    });

    on<RegisterFieldChanged>((event, emit) {
      // Validate email format
      final emailValid = RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(event.email);

      // Validate mobile number format (Malta format: 356XXXXXXXX)
      final mobileValid = RegExp(r'^356\d{8}$').hasMatch('356${event.mobileNo}');

      // Validate password length
      final passValid = _validatePassword(event.password);

      // Additional validations as needed...

      // Check if all fields are non-empty and validations pass
      final isFormValid = event.username.isNotEmpty &&
          emailValid &&
          mobileValid &&
          passValid;

      // Update the state
      if (state is RegisterInitial) {
        final currentState = state as RegisterInitial;
        emit(currentState.copyWith(isFormValid: isFormValid));
      } else {
        emit(RegisterInitial(isFormValid: isFormValid));
      }
    });
  }
  bool _validatePassword(String password) {
    return password.length >= 8;
  }
}


