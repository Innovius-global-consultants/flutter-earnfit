import 'package:equatable/equatable.dart';

abstract class RegisterEvent extends Equatable {
  const RegisterEvent();

  @override
  List<Object?> get props => [];
}

class RegisterSubmitted extends RegisterEvent {
  final String username;
  final String email;
  final String mobileNo;
  final String password;

  const RegisterSubmitted({
    required this.username,
    required this.email,
    required this.mobileNo,
    required this.password,
  });

  @override
  List<Object?> get props => [username, email, mobileNo, password];
}

class TogglePasswordVisibility extends RegisterEvent {
  const TogglePasswordVisibility();

  @override
  List<Object?> get props => [];
}
