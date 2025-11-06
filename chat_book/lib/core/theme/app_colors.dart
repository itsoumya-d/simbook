import 'package:flutter/material.dart';

/// App color scheme with dark theme and premium orange accents
/// Migrated from SoBrief web application CSS variables
class AppColors {
  AppColors._();

  // Premium Orange Accents
  static const Color primaryOrange = Color(0xFFFF8C42);
  static const Color primaryOrangeLight = Color(0xFFFFB366);
  static const Color primaryOrangeDark = Color(0xFFE67A2E);
  
  // Dark Theme Colors (migrated from CSS --theme-dark)
  static const Color darkBackground = Color(0xFF121212); // --page-bg-colors: 18, 18, 18
  static const Color darkSurface = Color(0xFF2C2C2C); // --bg1: rgb(44, 44, 44)
  static const Color darkSurfaceVariant = Color(0xFF1E1E1E); // --bg2: rgb(30, 30, 30)
  static const Color darkCard = Color(0xFF222222); // --bg3: rgb(34, 34, 34)
  static const Color darkElevated = Color(0xFF232323); // --bg4: rgb(35, 35, 35)
  static const Color darkInput = Color(0xFF2D2D2D); // --input-bg: rgb(45, 45, 45)
  
  // Text Colors (migrated from CSS)
  static const Color darkTextPrimary = Color(0xFFECECEC); // --text-color: rgb(236, 236, 236)
  static const Color darkTextSecondary = Color(0x80FFFFFF); // --text-color2: rgba(255, 255, 255, 0.5)
  static const Color darkTextTertiary = Color(0x59FFFFFF); // --text-color3: rgba(255, 255, 255, 0.35)
  static const Color darkTextQuaternary = Color(0xCCFFFFFF); // --text-color4: rgba(255, 255, 255, 0.8)
  
  // Light Theme Colors (for comparison/fallback)
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFFAFAFA);
  static const Color lightTextPrimary = Color(0xFF000000);
  static const Color lightTextSecondary = Color(0x99000000);
  
  // Accent Colors
  static const Color linkColor = Color(0xFF4DA3FF); // --link-color: rgb(77, 163, 255)
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color errorColor = Color(0xFFF44336);
  
  // Border Colors
  static const Color darkBorder = Color(0x33FFFFFF); // --border-color: rgba(255, 255, 255, 0.2)
  static const Color darkBorderSecondary = Color(0x33FFFFFF); // --border-color2: rgba(255, 255, 255, 0.2)
  static const Color darkDivider = Color(0xFF464646); // --border-color3: rgb(70, 70, 70)
  
  // Interactive Colors
  static const Color darkHover = Color(0xFF3B3B3B); // --menu-bg-hover: rgb(59, 59, 59)
  static const Color darkPressed = Color(0xFF404040);
  static const Color darkSelected = Color(0xFF2A2A2A);
  
  // Progress & Loading Colors
  static const Color progressBackground = Color(0x40FFFFFF); // --progress-bg: rgba(255, 255, 255, 0.25)
  static const Color progressHandle = Color(0xFFFFFFFF); // --progress-handle: rgba(255, 255, 255, 1)
  
  // Rating Stars
  static const Color starFilled = Color(0xFFFFD700);
  static const Color starEmpty = Color(0xFF404040);
  
  // Gradient Colors for Premium Feel
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryOrange, primaryOrangeDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient surfaceGradient = LinearGradient(
    colors: [darkSurface, darkSurfaceVariant],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  // Shadow Colors
  static const Color shadowColor = Color(0x40000000);
  static const Color elevationShadow = Color(0x20000000);
  
  // Book Cover Placeholder
  static const Color coverPlaceholder = Color(0xFF3A3A3A);
  
  // Audio Player Colors
  static const Color audioPlayerBackground = Color(0xFF1A1A1A);
  static const Color audioPlayerControl = Color(0xFFFFFFFF);
  static const Color audioWaveform = primaryOrange;
}