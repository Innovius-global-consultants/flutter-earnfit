import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

// Events
abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthStarted extends AuthEvent {}
class AuthLoggedIn extends AuthEvent {}
class AuthLoggedOut extends AuthEvent {}

// States
abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthAuthenticated extends AuthState {}
class AuthUnauthenticated extends AuthState {}

// Bloc
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial());

  @override
  Stream<AuthState> mapEventToState(AuthEvent event) async* {
    if (event is AuthStarted) {
      yield AuthLoading();
      // Simulate a delay for the authentication process
      await Future.delayed(const Duration(seconds: 2));
      yield AuthUnauthenticated();
    } else if (event is AuthLoggedIn) {
      yield AuthAuthenticated();
    } else if (event is AuthLoggedOut) {
      yield AuthUnauthenticated();
    }
  }
}
