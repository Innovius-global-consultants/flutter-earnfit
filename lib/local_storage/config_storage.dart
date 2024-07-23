import 'package:earnfit/services/model/config/config_data.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ConfigStorage {
  static const FlutterSecureStorage secureStorage = FlutterSecureStorage();

  // Method to store user config data securely
  static Future<void> storeConfigData(Map<String, dynamic> userConfigData) async {

    try {
      final configData = ConfigData.fromJson(userConfigData);

      print('configData');
      print(configData.caloriesPerStep);
      // Store the config information securely using flutter_secure_storage
      await secureStorage.write(
          key: 'caloriesPerStep', value: configData.caloriesPerStep);
      await secureStorage.write(
          key: 'earningPointPerStep', value: configData.earningPointPerStep);
      await secureStorage.write(
          key: 'earningMoneyPerStep', value: configData.earningMoneyPerStep);
      await secureStorage.write(
          key: 'appStoreLink', value: configData.appStoreLink);
      await secureStorage.write(
          key: 'playStoreLink', value: configData.playStoreLink);
      await secureStorage.write(
          key: 'invitationMsgText', value: configData.invitationMsgText);
    }catch(e){

      print('exfeptit0onnn');
      print(e);

    }
  }


  // Getters to retrieve each configuration value
  static Future<String?> getId() async {
    return await secureStorage.read(key: 'id');
  }

  static Future<String?> getCaloriesPerStep() async {
    return await secureStorage.read(key: 'caloriesPerStep');
  }

  static Future<String?> getEarningPointPerStep() async {
    return await secureStorage.read(key: 'earningPointPerStep');
  }

  static Future<String?> getEarningMoneyPerStep() async {
    return await secureStorage.read(key: 'earningMoneyPerStep');
  }

  static Future<String?> getAppStoreLink() async {
    return await secureStorage.read(key: 'appStoreLink');
  }

  static Future<String?> getPlayStoreLink() async {
    return await secureStorage.read(key: 'playStoreLink');
  }

  static Future<String?> getInvitationMsgText() async {
    return await secureStorage.read(key: 'invitationMsgText');
  }

  // Method to delete user config data securely
  static Future<void> deleteConfigData() async {
    await secureStorage.delete(key: 'id');
    await secureStorage.delete(key: 'caloriesPerStep');
    await secureStorage.delete(key: 'earningPointPerStep');
    await secureStorage.delete(key: 'earningMoneyPerStep');
    await secureStorage.delete(key: 'appStoreLink');
    await secureStorage.delete(key: 'playStoreLink');
    await secureStorage.delete(key: 'invitationMsgText');
  }
}

