import 'dart:convert'; // Ensure you import this for JSON decoding
import 'package:dio/dio.dart';
import 'package:earnfit/services/model/dashboard/steps_info.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../api_service.dart';

class HomeRepository {
  final APIService apiService = APIService.instance;
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  Future<StepsInfo> fetchTodayStepsInfo() async {
    try {
      final userId = await _fetchUserIdFromStorage();
      if (userId == null) {
        throw Exception('User ID is null');
      }

      final response = await apiService.request(
        '/get-today-steps-info/$userId',
        DioMethod.get,
      );

      return _handleStepsInfoResponse(response);
    } catch (e) {
      print('Exception during fetchTodayStepsInfo: $e');
      throw e;
    }
  }

  StepsInfo _handleStepsInfoResponse(Response response) {
    try {
      final responseData = response.data;
      if (responseData != null) {
        return StepsInfo.fromJson(responseData);
      } else {
        throw Exception('Failed to parse steps info response');
      }
    } catch (e) {
      print('Exception handling steps info response: $e');
      throw Exception('Failed to parse steps info response');
    }
  }

  Future<int> _fetchUserIdFromStorage() async {
    final userId = await secureStorage.read(key: 'id');
    if (userId != null) {
      return int.parse(userId);
    } else {
      throw Exception('User ID not found in storage');
    }
  }
}
