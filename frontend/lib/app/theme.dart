import 'package:flutter/material.dart';

class AppTheme {
  static const Color background = Color(0xFFF4F7F7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color primary = Color(0xFF0F7C7A);
  static const Color primaryDark = Color(0xFF0B5F5C);
  static const Color primarySoft = Color(0xFFDFF5F2);
  static const Color navy = Color(0xFF16313D);
  static const Color charcoal = Color(0xFF27363D);
  static const Color green = Color(0xFF2AA77E);
  static const Color greenSoft = Color(0xFFE4F7F0);
  static const Color amber = Color(0xFFE4A848);
  static const Color amberSoft = Color(0xFFFDF0D7);
  static const Color red = Color(0xFFE65D5A);
  static const Color redSoft = Color(0xFFFAE5E2);
  static const Color blue = Color(0xFF4E8FD7);
  static const Color blueSoft = Color(0xFFEAF3FF);
  static const Color muted = Color(0xFF6F7E86);
  static const Color line = Color(0xFFE6EBED);
  static const Color shadow = Color(0x1A0F2E32);

  static ThemeData get lightTheme {
    final base = ThemeData(
      useMaterial3: true,
      fontFamily: 'Roboto',
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
        primary: primary,
        secondary: green,
        surface: surface,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        color: surface,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        elevation: 0,
        indicatorColor: primarySoft,
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF1F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: background,
        foregroundColor: navy,
      ),
    );

    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: navy,
        displayColor: navy,
      ),
    );
  }
}
