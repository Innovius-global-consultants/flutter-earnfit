import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../api_service.dart';
import '../model/user/user.dart';

class AuthRepository {
  final APIService apiService = APIService.instance;
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  Future<void> login(String email, String password) async {
    final response = await apiService.request(
      '/login',
      DioMethod.post,
      param: {'email': email, 'password': password},
    );
    _handleResponse(response);
  }

  Future<void> register({
    required String username,
    required String mobile_no,
    required String email,
    required String password,
  }) async {
    final response = await apiService.request(
      '/register',
      DioMethod.post,
      param: {
        'username': username,
        'mobile_no': mobile_no,
        'email': email,
        'password': password,
      },
    );
    _handleResponse(response);
  }

  // Common method to handle API responses
  void _handleResponse(Response response) {
    final responseData = response.data;

    // Check if the response data is not null and contains the 'data' key
    if (responseData != null && responseData.containsKey('data')) {
      final data = responseData['data'];

      // Check if the 'token' key exists in the 'data' object
      if (data != null && data.containsKey('token')) {
        final token = data['token'];

        // Ensure that the token is a string
        if (token is String) {
          // Set the token in the API service
          apiService.setToken(token);
          // Store the token securely for future use
          _storeToken(token);

          // Store additional user information
          if (data.containsKey('user_data')) {
            final userData = data['user_data'];
            _storeUserData(userData);
          } else {
            throw Exception('User data not found in response');
          }
        } else {
          // Handle the case where the token is not a string
          throw Exception('Token is not a string');
        }
      } else {
        // Handle the case where the 'token' key is missing in the response
        throw Exception('Token not found in response');
      }
    } else {
      // Handle the case where the 'data' key is missing in the response
      throw Exception('Data not found in response');
    }
  }

  // Method to securely store the token
  Future<void> _storeToken(String token) async {
    // Store the token securely using flutter_secure_storage
    await secureStorage.write(key: 'auth_token', value: token);
  }

  // Method to store user data securely
  Future<void> _storeUserData(Map<String, dynamic> userData) async {
    // Extract user information from userData
    final user = User.fromJson(userData);

    // Store the user information securely using flutter_secure_storage or any other preferred method
    await secureStorage.write(key: 'user_id', value: user.userId.toString());
    await secureStorage.write(key: 'username', value: user.username);
    await secureStorage.write(key: 'email', value: user.email);
    await secureStorage.write(key: 'mobile', value: user.mobile);
  }
}
