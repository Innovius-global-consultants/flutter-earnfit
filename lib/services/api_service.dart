import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../auth/auth.dart';

enum DioMethod { post, get, put, delete }

class APIService {
  APIService._singleton();

  static final APIService instance = APIService._singleton();
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  String get baseUrl {
    if (kDebugMode) {
      return 'https://api.innoviusconsultants.com/api';
    }
    return 'https://api.innoviusconsultants.com/api';
  }

  Future<void> setTokenFromStorage() async {
    final token = await Auth.getToken();
    if (token != null) {
      setToken(token);
    }
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


      print('getToken  request');
      print(getToken());
      final dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          contentType: 'application/json',
          headers: {
            HttpHeaders.authorizationHeader: 'Bearer ${await getToken()}',
          },
        ),
      );

      final options = Options(
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer ${await getToken()}',
        },
      );

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
    } on DioError catch (e) {
      if (e.response?.statusCode == 401) {
        // Handle token refresh or logout scenario here
        // For simplicity, we'll throw an error for now
        throw Exception('Unauthorized: Token expired or invalid');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      print('Exceptionsdf');
      print(e);
      throw Exception('Error: $e');
    }
  }
}
