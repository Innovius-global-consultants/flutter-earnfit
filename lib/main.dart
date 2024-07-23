import 'package:earnfit/configs/Singletons/singletons.dart';
import 'package:flutter/material.dart';

import 'configs/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>(); // Replace this with your actual flavor base

  @override
  void initState() {
    super.initState();
    _registerSingletons();
  }

  Future<void> _registerSingletons() async {
    await Singletons.register(
      navigatorKey,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: AppRouter.router,
      theme: ThemeData(
        // Define your theme data here
        primarySwatch: Colors.blue,
        // Add more theme configurations as needed
      ),
    );
  }
}
