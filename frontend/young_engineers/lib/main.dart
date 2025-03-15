import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:young_engineers/app/routes/app_pages.dart';
import 'app/modules/splash/views/splash_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Young Engineers',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      home: const SplashView(),
    );
  }
}
