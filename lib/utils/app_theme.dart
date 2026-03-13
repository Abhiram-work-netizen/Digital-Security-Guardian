import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App Theme — Modern dark theme with teal/indigo gradient palette
class AppTheme {
  // Brand Colors
  static const Color primary = Color(0xFF3B82F6); // Neon Blue
  static const Color primaryDark = Color(0xFF00897B); // This line is not explicitly changed in the snippet, keeping it.
  static const Color secondary = Color(0xFF8B5CF6); // Purple
  static const Color secondaryDark = Color(0xFF3949AB); // This line is not explicitly changed in the snippet, keeping it.
  static const Color accent = Color(0xFFFBBF24); // Neon Yellow (for Alerts)

  // Background colors
  // V3 Cosmic Theme Colors
  static const Color background = Color(0xFF0F172A); // Deep navy blue
  static const Color surface = Color(0xFF161B22); // This line is not explicitly changed in the snippet, keeping it.
  static const Color surfaceLight = Color(0xFF1E293B); // Lighter blue-grey for cards
  static const Color cardColor = Color(0xFF172554); // Very dark blue for cards

  // Text colors
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFFCBD5E1);
  static const Color textMuted = Color(0xFF64748B);

  // Risk severity colors
  static const Color riskHigh = Color(0xFFEF4444); // Red
  static const Color riskMedium = Color(0xFFF59E0B); // Amber/Orange
  static const Color riskLow = Color(0xFF3B82F6); // Blue
  static const Color safe = Color(0xFF10B981); // Emerald Green

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF020617), Color(0xFF0F172A)], // Super deep space blue
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient scoreGradient = LinearGradient(
    colors: [Color(0xFF00BFA6), Color(0xFF26C6DA), Color(0xFF5C6BC0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: surface,
        error: riskHigh,
      ),
      scaffoldBackgroundColor: background,
      cardColor: cardColor,
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme,
      ).apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: background,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        hintStyle: const TextStyle(color: textMuted),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
