// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryDark = Color(0xFF2C3E50);
  static const Color primaryLight = Color(0xFF3498DB);
  static const Color studentColor = Color(0xFF1ABC9C);
  static const Color companyColor = Color(0xFFE74C3C);
  static const Color background = Color(0xFFF8F9FA);
}

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    primaryColor: AppColors.primaryDark,
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primaryDark,
      elevation: 0,
    ),
  );
}