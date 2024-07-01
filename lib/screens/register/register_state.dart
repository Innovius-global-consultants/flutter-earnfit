import 'package:earnfit/screens/register/register_event.dart';
import 'package:equatable/equatable.dart';

abstract class RegisterState extends Equatable {
  const RegisterState();

  @override
  List<Object?> get props => [];
}

class RegisterInitial extends RegisterState {
  final bool isPasswordVisible;
  final bool isFormValid;

  const RegisterInitial({
    this.isPasswordVisible = false,
    this.isFormValid = false,
  });

  @override
  List<Object?> get props => [isPasswordVisible, isFormValid];

  RegisterInitial copyWith({
    bool? isPasswordVisible,
    bool? isFormValid,
  }) {
    return RegisterInitial(
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      isFormValid: isFormValid ?? this.isFormValid,
    );
  }
}

class RegisterFieldChanged extends RegisterEvent {
  final String username;
  final String email;
  final String mobileNo;
  final String password;

  const RegisterFieldChanged({
    required this.username,
    required this.email,
    required this.mobileNo,
    required this.password,
  });
}

class RegisterLoading extends RegisterState {}

class RegisterSuccess extends RegisterState {}

class RegisterFailure extends RegisterState {
  final String error;

  const RegisterFailure(this.error);

  @override
  List<Object?> get props => [error];
}
