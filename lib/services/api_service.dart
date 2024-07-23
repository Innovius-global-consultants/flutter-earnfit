import 'dart:io';
import 'package:dio/dio.dart';
import 'package:earnfit/commons/location_service.dart';
import 'package:earnfit/local_storage/auth/auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


enum DioMethod { post, get, put, delete }

class APIService {
  APIService._singleton();

  static final APIService instance = APIService._singleton();
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  final LocationService locationService = LocationService();

  String get baseUrl {
    return 'https://api.innoviusconsultants.com/api';
  }

  Future<void> setTokenFromStorage() async {
    final token = await Auth.getToken();
    if (token != null) {
      setToken(token);
    }
  }

  Future<String?> getCurrentLocation() async {
    return await secureStorage.read(key: 'current_location');
  }

  void setToken(String token) {
    Auth.saveToken(token);
  }

  Future<String?> getToken() async {
    return await Auth.getToken();
  }

  Future<Response> request(
      String endpoint,
      DioMethod method, {
        Map<String, dynamic>? param,
        String? contentType,
        formData,
      }) async {
    try {
      final token = await getToken();
      final dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          contentType: 'application/json',
          headers: {
            HttpHeaders.authorizationHeader: token != null ? 'Bearer $token' : '',
          },
        ),
      );

      final options = Options(
        headers: {
          HttpHeaders.authorizationHeader: token != null ? 'Bearer $token' : '',
        },
      );

      if (endpoint != '/register' || endpoint != '/login') {
        print('notloginAPi');

        final currentLocation = await getCurrentLocation();

        print('currentLocation');
        print(currentLocation);

        if (currentLocation != null) {
          options.headers!.addAll({
            'Longitude': currentLocation.split(',')[0],
            'Latitude': currentLocation.split(',')[1],
          });
        }
      }

      switch (method) {
        case DioMethod.post:
          return dio.post(endpoint, data: param ?? formData, options: options);
        case DioMethod.get:
          return dio.get(endpoint, queryParameters: param, options: options);
        case DioMethod.put:
          return dio.put(endpoint, data: param ?? formData, options: options);
        case DioMethod.delete:
          return dio.delete(endpoint, data: param ?? formData, options: options);
        default:
          return dio.post(endpoint, data: param ?? formData, options: options);
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        // Handle token refresh or logout scenario here
        // For simplicity, we'll throw an error for now
        throw Exception('Unauthorized: Token expired or invalid');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
