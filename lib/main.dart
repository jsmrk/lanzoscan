import 'package:flutter/material.dart';
import 'package:lanzoscan/pages/home.dart';
import 'package:lanzoscan/pages/splash.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LanzoScan',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0x0ffee5a2)),
        useMaterial3: true,
      ),
      home: const Splashscreen(),
    );
  }
}
