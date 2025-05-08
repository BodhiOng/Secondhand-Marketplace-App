import 'package:flutter/material.dart';
import 'package:secondhand_marketplace_app/constants.dart';
import 'landing_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ThriftNest',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          secondary: Colors.orangeAccent,
        ),
        fontFamily: 'Poppins',
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: AppColors.charcoalBlack,
          foregroundColor: AppColors.coolGray,
          centerTitle: true,
        ),
        scaffoldBackgroundColor: AppColors.charcoalBlack,
        pageTransitionsTheme: PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
            TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      home: const LandingPage(), // Will navigate to MyHomePage after animation
    );
  }
}