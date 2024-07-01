import 'package:earnfit/configs/app_colors.dart';
import 'package:earnfit/screens/register/register_bloc.dart';
import 'package:earnfit/screens/register/register_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../configs/app_text_styles.dart';
import '../../services/repository/auth_repository.dart';
import 'register_event.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // Define state variables for error messages
  String? _emailError;
  String? _mobileError;
  String? _passwordError;
  bool isSignupButtonEnabled = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RegisterBloc(authRepository: AuthRepository()),
      child: BlocListener<RegisterBloc, RegisterState>(
        listener: (context, state) {
          if (state is RegisterSuccess) {
            context.go('/dashboard');
          } else if (state is RegisterFailure) {
            setState(() {
              isSignupButtonEnabled = true;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 30),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        'assets/icons/bird.png', // Path to your bird icon asset
                        width: 75,
                        height: 75,
                        color: AppColors.black,
                      ),
                      Text(
                        'EARNFIT',
                        style: AppTextStyles.openSans.copyWith(
                          fontSize: 32,
                          color: AppColors.black,
                        ),
                      ),
                      Text(
                        'Sign up to join the biggest community',
                        textAlign: TextAlign.left,
                        style: AppTextStyles.openSans.copyWith(
                          fontSize: 14,
                          color: AppColors.lightGrey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Text(
                    'Name',
                    style: AppTextStyles.openSans.copyWith(
                      fontSize: 14,
                      color: AppColors.black,
                    ),
                  ),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: 'Enter your name',
                      hintStyle: AppTextStyles.openSans
                          .copyWith(color: AppColors.hintColor),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: AppColors.underlineTextField),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.black),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 0), // Set vertical padding to zero
                    ),
                    onChanged: (value) => _onFieldChanged(context),
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
                      hintStyle: AppTextStyles.openSans
                          .copyWith(color: AppColors.hintColor),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: AppColors.underlineTextField),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.black),
                      ),
                      errorText: _emailError,
                      errorStyle: const TextStyle(color: Colors.red),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (value) {
                      _validateEmail(value); // Validate email format
                      _onFieldChanged(context);
                    },
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'Mobile number',
                    style: AppTextStyles.openSans.copyWith(
                      fontSize: 14,
                      color: AppColors.black,
                    ),
                  ),
                  TextField(
                    controller: mobileController,
                    decoration: InputDecoration(
                      hintText: 'Enter your mobile number',
                      hintStyle: AppTextStyles.openSans
                          .copyWith(color: AppColors.hintColor),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: AppColors.underlineTextField),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.black),
                      ),
                      errorText: _mobileError,
                      prefixText: '356 ',
                      prefixStyle: AppTextStyles.openSans.copyWith(
                        color: AppColors.black,
                        fontSize: 14,
                      ),
                      // Matching the prefix color with hint color
                      errorStyle: const TextStyle(color: Colors.red),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                    keyboardType: TextInputType.phone,
                    onChanged: (value) {
                      _validateMobile(value); // Validate phone number format
                      _onFieldChanged(context);
                    },
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'Password',
                    style: AppTextStyles.openSans.copyWith(
                      fontSize: 14,
                      color: AppColors.black,
                    ),
                  ),
                  BlocBuilder<RegisterBloc, RegisterState>(
                    builder: (context, state) {
                      bool isPasswordVisible = state is RegisterInitial
                          ? state.isPasswordVisible
                          : false;
                      return TextField(
                        controller: passwordController,
                        decoration: InputDecoration(
                          hintText: 'Enter your password',
                          errorText: _passwordError,
                          // Use state variable for error text
                          errorStyle: const TextStyle(color: Colors.red),
                          hintStyle: AppTextStyles.openSans
                              .copyWith(color: AppColors.hintColor),
                          enabledBorder: const UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: AppColors.underlineTextField),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.black),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: AppColors.hintColor,
                            ),
                            onPressed: () {
                              context
                                  .read<RegisterBloc>()
                                  .add(const TogglePasswordVisibility());
                            },
                          ),
                        ),
                        obscureText: !isPasswordVisible,
                        onChanged: (value) {
                          // Check password length and set error message accordingly
                          setState(() {
                            _passwordError = _validatePassword(value)
                                ? null
                                : 'Password must be at least 8 characters';
                          });
                          _onFieldChanged(context);
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 30),
                  BlocBuilder<RegisterBloc, RegisterState>(
                    builder: (context, state) {
                      if (state is RegisterLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      bool isFormValid =
                          state is RegisterInitial ? state.isFormValid : false;

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5.0, vertical: 5.0),
                        child: ElevatedButton(
                          onPressed: isSignupButtonEnabled || isFormValid
                              ? () {
                                  context.read<RegisterBloc>().add(
                                        RegisterSubmitted(
                                          username: nameController.text,
                                          email: emailController.text,
                                          mobileNo: mobileController.text,
                                          password: passwordController.text,
                                        ),
                                      );
                                }
                              : null,
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) {
                                if (states.contains(MaterialState.disabled)) {
                                  return Colors
                                      .grey; // Color when the button is disabled
                                }
                                return AppColors
                                    .buttonColor; // Color when the button is enabled
                              },
                            ),
                            foregroundColor:
                                MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) {
                                if (states.contains(MaterialState.disabled)) {
                                  return Colors
                                      .white; // Text color when the button is disabled
                                }
                                return Colors
                                    .white; // Text color when the button is enabled
                              },
                            ),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12.0, vertical: 12.0),
                            child: Text(
                              'Sign Up',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      context.go('/login');
                    },
                    child: Text.rich(
                      TextSpan(
                        text: 'Have an account? ',
                        style: AppTextStyles.openSans.copyWith(
                          color: AppColors.lightGrey,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: 'Sign in',
                            style: AppTextStyles.openSans.copyWith(
                              color: AppColors.buttonColor,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onFieldChanged(BuildContext context) {
    context.read<RegisterBloc>().add(
          RegisterFieldChanged(
            username: nameController.text,
            email: emailController.text,
            mobileNo: mobileController.text,
            password: passwordController.text,
          ),
        );
  }

  void _validateEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    setState(() {
      _emailError = emailRegex.hasMatch(email) ? null : 'Invalid email';
    });
  }

  void _validateMobile(String mobile) {
    // Ensure the mobile number is exactly 8 digits after the prefix '356'
    final mobileRegex = RegExp(r'^\d{8}$');

    // Remove the prefix '356' from the input before validation
    final mobileWithoutPrefix =
        mobile.startsWith('356') ? mobile.substring(3) : mobile;

    setState(() {
      _mobileError = mobileRegex.hasMatch(mobileWithoutPrefix)
          ? null
          : 'Invalid phone number';
    });
  }

  bool _validatePassword(String password) {
    return password.length >= 8;
  }
}
