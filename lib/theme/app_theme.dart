import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF00A99D);
  static const Color primaryDarkColor = Color(0xFF00897B);

  static const Color backgroundColor = Color(0xFFFFF4EF);
  static const Color cardColor = Color(0xFFFFE9DF);
  static const Color cardBorderColor = Color(0xFFFFCEBE);

  static const Color accentColor = Color(0xFFFF8A65);
  static const Color textColor = Color(0xFF263238);
  static const Color secondaryTextColor = Color(0xFF607D8B);

  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,

      scaffoldBackgroundColor: backgroundColor,

      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: accentColor,
        surface: cardColor,
        error: Colors.red,
      ),

      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: primaryDarkColor,
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          fontFamily: 'monospace',
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 2,
        ),
        shape: Border(
          bottom: BorderSide(
            color: secondaryTextColor,
            width: 0.6,
          ),
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: cardColor,
        indicatorColor: primaryColor.withValues(alpha: 0.25),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(
              color: primaryDarkColor,
              size: 36,
            );
          }

          return const IconThemeData(
            color: secondaryTextColor,
            size: 36,
          );
        }),
      ),

      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.75),
        margin: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 6,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(
            color: cardBorderColor,
            width: 1,
          ),
        ),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        labelStyle: const TextStyle(
          color: secondaryTextColor,
        ),
        hintStyle: const TextStyle(
          color: secondaryTextColor,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: cardBorderColor,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: cardBorderColor,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: primaryColor,
            width: 2,
          ),
        ),
      ),

      textTheme: const TextTheme(
        bodySmall: TextStyle(
          color: secondaryTextColor,
        ),
        bodyMedium: TextStyle(
          color: textColor,
        ),
        bodyLarge: TextStyle(
          color: textColor,
        ),
        titleMedium: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
        headlineSmall: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),

      iconTheme: const IconThemeData(
        color: primaryColor,
      ),

      listTileTheme: const ListTileThemeData(
        iconColor: primaryColor,
        textColor: textColor,
      ),

      dividerTheme: const DividerThemeData(
        color: cardBorderColor,
      ),
    );
  }
}