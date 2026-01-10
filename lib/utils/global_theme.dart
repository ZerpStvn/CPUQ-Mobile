import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// CPU University Color Palette
const primaryColor = Color(0xFF03236D); // CPU Blue
const secondaryColor = Color(0xFFFFB800); // CPU Gold
const neutralWhite = Color(0xFFFFFFFF);
const backgroundGray = Color(0xFFF5F7FA);
const textDark = Color(0xFF1A1A1A);
const textGray = Color(0xFF6B7280);
const cardBackground = Color(0xFFFFFFFF);
const dividerColor = Color(0xFFE5E7EB);

// App Theme
ThemeData getAppTheme() {
  return ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundGray,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: cardBackground,
      error: Color(0xFFDC2626),
    ),
    textTheme: GoogleFonts.poppinsTextTheme(
      const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textDark,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: textDark,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textDark,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: textGray,
        ),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: neutralWhite,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textDark,
      ),
      iconTheme: const IconThemeData(color: textDark),
    ),
    cardTheme: CardThemeData(
      color: cardBackground,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: neutralWhite,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  );
}
