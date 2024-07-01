import 'package:flutter/material.dart';

import 'configs/app_router.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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
