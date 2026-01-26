import 'package:flutter/material.dart';
import 'colors.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryGreen,
        primary: AppColors.primaryGreen,
        secondary: AppColors.accentYellow,
        background: AppColors.backgroundLight,
        surface: AppColors.surfaceWhite,
        error: AppColors.errorRed,
      ),
      textTheme: GoogleFonts.outfitTextTheme().copyWith(
        displayLarge: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
        titleLarge: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.earthBrown), // Earthy titles
        bodyLarge: const TextStyle(fontSize: 16, color: AppColors.textBlack),
        bodyMedium: const TextStyle(fontSize: 14, color: AppColors.textGrey),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56), // Large touch target
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), // Softer corners
          elevation: 4,
          shadowColor: AppColors.primaryGreen.withOpacity(0.4),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        hoverColor: AppColors.lightGreen.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16), // Softer corners
          borderSide: BorderSide(color: AppColors.primaryGreen.withOpacity(0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.primaryGreen.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.errorRed),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        prefixIconColor: AppColors.primaryGreen,
      ),

    );
  }
}
