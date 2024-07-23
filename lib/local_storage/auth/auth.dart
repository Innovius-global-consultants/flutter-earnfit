import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Auth {
  static const FlutterSecureStorage secureStorage = FlutterSecureStorage();

  static Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null;
  }

  static Future<void> saveToken(String token) async {
    await secureStorage.write(key: 'auth_token', value: token);
  }

  static Future<String?> getToken() async {
    return await secureStorage.read(key: 'auth_token');
  }

  static Future<void> deleteToken() async {
    await secureStorage.delete(key: 'auth_token');
  }
}
