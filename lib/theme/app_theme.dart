// lib/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  static final _seed = Colors.teal;

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: _seed),
        scaffoldBackgroundColor: ColorScheme.fromSeed(seedColor: _seed).background,

        // AppBar
        appBarTheme: AppBarTheme(
          backgroundColor: ColorScheme.fromSeed(seedColor: _seed).surface,
          elevation: 0,
          iconTheme: IconThemeData(color: ColorScheme.fromSeed(seedColor: _seed).onSurface),
          titleTextStyle: TextStyle(
            color: ColorScheme.fromSeed(seedColor: _seed).onSurface,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),

        // Cards
        cardTheme: CardTheme(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        ),

        // Buttons & FAB
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 1,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: ColorScheme.fromSeed(seedColor: _seed).primary,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),

        // Inputs
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: ColorScheme.fromSeed(seedColor: _seed).surfaceVariant,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        ),

        // Typography (optional tweaks)
        textTheme: Typography.material2021().black.apply(
          bodyColor: ColorScheme.fromSeed(seedColor: _seed).onBackground,
          displayColor: ColorScheme.fromSeed(seedColor: _seed).onBackground,
        ),
      );
}
