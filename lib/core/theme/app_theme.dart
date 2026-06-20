import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData lightTheme =
  ThemeData(
    brightness: Brightness.light,

    primaryColor: AppColors.primary,

    scaffoldBackgroundColor:
    AppColors.lightBackground,

    cardColor: AppColors.lightCard,

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
    ),

    elevatedButtonTheme:
    ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor:
        AppColors.primary,
        foregroundColor:
        Colors.white,
      ),
    ),
  );

  static ThemeData darkTheme =
  ThemeData(
    brightness: Brightness.dark,

    primaryColor: AppColors.primary,

    scaffoldBackgroundColor:
    AppColors.darkBackground,

    cardColor: AppColors.darkCard,

    appBarTheme: const AppBarTheme(
      backgroundColor:
      AppColors.darkCard,
      foregroundColor:
      Colors.white,
      elevation: 0,
      centerTitle: false,
      toolbarHeight: 64,
    ),

    elevatedButtonTheme:
    ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor:
        AppColors.primary,
        foregroundColor:
        Colors.white,
      ),
    ),
  );
}