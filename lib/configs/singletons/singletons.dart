import 'package:earnfit/core/contacts.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class Singletons {
  const Singletons._();


  static Future<void> register(
       GlobalKey<NavigatorState> navigatorKey,
      ) async {
    GetIt.instance.registerSingleton(navigatorKey);
    GetIt.instance.registerSingleton(const Contacts());
  }

  static Contacts get contacts {
    return GetIt.instance<Contacts>();
  }
}