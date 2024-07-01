import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../configs/app_colors.dart';
import '../../configs/app_text_styles.dart';
import '../../services/repository/auth_repository.dart';
import 'login_bloc.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginBloc(authRepository: AuthRepository()),
      child: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state is LoginSuccess) {
            context.go('/dashboard');
          } else if (state is LoginFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Invalid email or password')),
            );
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Padding(
            padding: const EdgeInsets.only(left: 40, right: 40, top: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset(
                  'assets/icons/bird.png', // Path to your bird icon asset
                  width: 75,
                  height: 75,
                  color: AppColors.black,
                ),
                Text(
                  'EARNFIT',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.openSans.copyWith(
                    fontSize: 32,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  'Email',
                  style: AppTextStyles.openSans.copyWith(
                    fontSize: 14,
                    color: AppColors.black,
                  ),
                ),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    hintText: 'Enter your email',
                    hintStyle: AppTextStyles.openSans.copyWith(
                      color: AppColors.hintColor,
                    ),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.underlineTextField),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.black),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 30),
                Text(
                  'Password',
                  style: AppTextStyles.openSans.copyWith(
                    fontSize: 14,
                    color: AppColors.black,
                  ),
                ),
                BlocBuilder<LoginBloc, LoginState>(
                  builder: (context, state) {
                    bool isPasswordVisible =
                    state is LoginInitial ? state.isPasswordVisible : false;
                    return TextField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        hintText: 'Enter your password',
                        hintStyle: AppTextStyles.openSans.copyWith(
                          color: AppColors.hintColor,
                        ),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: AppColors.underlineTextField),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: AppColors.black),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                            color: AppColors.black,
                          ),
                          onPressed: () {
                            context.read<LoginBloc>().add(const TogglePasswordVisibility());
                          },
                        ),
                      ),
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: !isPasswordVisible,
                    );
                  },
                ),
                const SizedBox(height: 30),
                BlocBuilder<LoginBloc, LoginState>(
                  builder: (context, state) {
                    if (state is LoginLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return ElevatedButton(
                      onPressed: () {
                        context.read<LoginBloc>().add(
                          LoginSubmitted(
                            username: emailController.text,
                            password: passwordController.text,
                          ),
                        );
                      },
                      style: ButtonStyle(
                        backgroundColor:
                        MaterialStateProperty.all<Color>(AppColors.buttonColor),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                        child: Text(
                          'Login',
                          style: AppTextStyles.openSans.copyWith(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    context.go('/register');
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Don\'t have an account? ',
                        style: AppTextStyles.openSans.copyWith(
                          color: AppColors.lightGrey,
                        ),
                      ),
                      Text(
                        'Sign up here',
                        style: AppTextStyles.openSans.copyWith(
                          color: AppColors.buttonColor,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
