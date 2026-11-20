import 'package:flutter/material.dart';

import 'screens/main_shell.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'pakelagi.',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Plus Jakarta Sans',
        scaffoldBackgroundColor: const Color(0xFFFBF8F3),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFB04B25),
          surface: const Color(0xFFFBF8F3),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Color(0xFF1D1A16)),
        ),
      ),
      home: const MainShell(),
    );
  }
}
