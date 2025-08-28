import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6750A4)),
      useMaterial3: true,
      snackBarTheme:
          const SnackBarThemeData(behavior: SnackBarBehavior.floating),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
    );
  }

  static ThemeData get dark {
    return ThemeData.dark(useMaterial3: true).copyWith(
      colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFB69DF8), brightness: Brightness.dark),
      snackBarTheme:
          const SnackBarThemeData(behavior: SnackBarBehavior.floating),
      inputDecorationTheme:
          const InputDecorationTheme(border: OutlineInputBorder()),
    );
  }
}
