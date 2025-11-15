import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Primary colors - Blue, White, Black
  static const Color primaryColor = Color(0xFF2962FF); // Blue
  static const Color white = Color(0xFFFFFFFF);        // White
  static const Color black = Color(0xFF000000);        // Black
  
  // Secondary shades of primary colors
  static const Color secondaryColor = Color(0xFF1565C0); // Secondary Blue
  static const Color lightBlue = Color(0xFF82B1FF);    // Light Blue
  static const Color darkBlue = Color(0xFF0039CB);     // Dark Blue
  static const Color grey = Color(0xFF757575);         // Grey for text
  static const Color lightGrey = Color(0xFFEEEEEE);    // Light Grey for backgrounds
  static const Color darkGrey = Color(0xFF212121);     // Dark Grey for dark mode backgrounds
  
  // Only for profit/loss indications
  static const Color positiveColor = Color(0xFF4CAF50); // Green
  static const Color negativeColor = Color(0xFFE53935); // Red
  
  // Backgrounds
  static const Color lightBackground = Color(0xFFF5F7FA); // Light mode background
  static const Color darkBackground = Color(0xFF121212);  // Dark mode background
  
  // Text colors
  static const Color textPrimary = Color(0xFF212121);     // Primary text for light mode
  static const Color textSecondary = Color(0xFF757575);   // Secondary text
  static const Color dividerColor = Color(0xFFE0E0E0);    // Divider color

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: darkBlue,
      background: lightBackground,
      surface: white,
      error: negativeColor,
      onPrimary: white,
      onSecondary: white,
      onBackground: textPrimary,
      onSurface: textPrimary,
      onError: white,
    ),
    scaffoldBackgroundColor: lightBackground,
    textTheme: _buildTextTheme(),
    appBarTheme: const AppBarTheme(
      backgroundColor: white,
      elevation: 0,
      iconTheme: IconThemeData(color: textPrimary),
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: white,
        minimumSize: const Size(100, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor),
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: dividerColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: dividerColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColor),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: negativeColor),
      ),
    ),
    cardTheme: CardThemeData(
      color: white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: white,
      selectedItemColor: primaryColor,
      unselectedItemColor: textSecondary,
      selectedLabelStyle: TextStyle(fontSize: 10),
      unselectedLabelStyle: TextStyle(fontSize: 10),
      type: BottomNavigationBarType.fixed,
    ),
    dividerTheme: const DividerThemeData(
      color: dividerColor,
      thickness: 1,
      space: 1,
    ),
    tabBarTheme: const TabBarThemeData(
      labelColor: primaryColor,
      unselectedLabelColor: textSecondary,
      indicatorColor: primaryColor,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: lightBlue,
      background: darkBackground,
      surface: darkGrey,
      error: negativeColor,
      onPrimary: white,
      onSecondary: white,
      onBackground: white,
      onSurface: white,
      onError: white,
    ),
    scaffoldBackgroundColor: darkBackground,
    textTheme: _buildTextTheme(isDark: true),
    appBarTheme: const AppBarTheme(
      backgroundColor: darkGrey,
      elevation: 0,
      iconTheme: IconThemeData(color: white),
      titleTextStyle: TextStyle(
        color: white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: white,
        minimumSize: const Size(100, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor),
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkGrey,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: darkGrey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: darkGrey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColor),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: negativeColor),
      ),
    ),
    cardTheme: CardThemeData(
      color: darkGrey,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: darkBackground,
      selectedItemColor: primaryColor,
      unselectedItemColor: grey,
      selectedLabelStyle: TextStyle(fontSize: 10),
      unselectedLabelStyle: TextStyle(fontSize: 10),
      type: BottomNavigationBarType.fixed,
    ),
    dividerTheme: const DividerThemeData(
      color: darkGrey,
      thickness: 1,
      space: 1,
    ),
    tabBarTheme: const TabBarThemeData(
      labelColor: primaryColor,
      unselectedLabelColor: grey,
      indicatorColor: primaryColor,
    ),
  );

  static TextTheme _buildTextTheme({bool isDark = false}) {
    final baseTextTheme = GoogleFonts.interTextTheme();
    final baseColor = isDark ? white : textPrimary;
    final secondaryBaseColor = isDark ? grey : textSecondary;

    return baseTextTheme.copyWith(
      displayLarge: baseTextTheme.displayLarge?.copyWith(
        color: baseColor,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: baseTextTheme.displayMedium?.copyWith(
        color: baseColor,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      displaySmall: baseTextTheme.displaySmall?.copyWith(
        color: baseColor,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: baseTextTheme.headlineMedium?.copyWith(
        color: baseColor,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: baseTextTheme.titleLarge?.copyWith(
        color: baseColor,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: baseTextTheme.titleMedium?.copyWith(
        color: baseColor,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: baseTextTheme.titleSmall?.copyWith(
        color: baseColor,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(
        color: baseColor,
        fontSize: 16,
        fontWeight: FontWeight.normal,
      ),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(
        color: baseColor,
        fontSize: 14,
        fontWeight: FontWeight.normal,
      ),
      bodySmall: baseTextTheme.bodySmall?.copyWith(
        color: secondaryBaseColor,
        fontSize: 12,
        fontWeight: FontWeight.normal,
      ),
    );
  }
} 