import 'dart:io';

class AppUtils {
  const AppUtils._();

  /// The runtime way to check if system is Android (can be mocked during test)
  static bool Function() _isAndroid = () => Platform.isAndroid;

  /// The runtime way to check if system is iOS (can be mocked during test)
  static bool Function() _isIos = () => Platform.isIOS;

  /// Check if system is Android
  static bool get isAndroid => _isAndroid();

  /// Check if system is iOS
  static bool get isIos => _isIos();

}