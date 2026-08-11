import 'package:flutter/material.dart';

class AppColors {
  // Common Colors
  static const Color primary = Color(0xFF436850); // Calm Sage Green
  static const Color primaryLight = Color(0xFFADBC9F); // Light Soft Sage
  static const Color primaryDark = Color(0xFF12372A); // Deep Forest Pine
  
  static const Color secondary = Color(0xFF8D7B68); // Warm Earthy Clay
  static const Color secondaryLight = Color(0xFFD8C4B6); // Soft Sand
  
  static const Color accent = Color(0xFFD4A373); // Soothing Honey Ochre
  static const Color warning = Color(0xFFEAB308); // Warm Amber
  static const Color error = Color(0xFFC85C5C); // Soft Dusty Coral Red

  // Dark Theme Palette (Deep Forest Charcoal Night)
  static const Color darkBg = Color(0xFF151C18); // Deep charcoal-pine green
  static const Color darkSurface = Color(0xFF1F2B24); // Dark forest surface
  static const Color darkSurfaceLight = Color(0xFF2E3E34); // Light forest surface
  static const Color darkTextPrimary = Color(0xFFECEFE7); // Soft warm linen white
  static const Color darkTextSecondary = Color(0xFFA8B4A9); // Muted sage grey
  static const Color darkTextMuted = Color(0xFF758577); // Deep sage grey
  static const Color glassBorder = Color(0xFF2E3E34);

  // Light Theme Palette (Warm Linen & Oat)
  static const Color lightBg = Color(0xFFF9F8F6); // Soft warm linen
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceLight = Color(0xFFF2EFE9); // Warm Oat
  static const Color lightTextPrimary = Color(0xFF1C2420); // Deep Pine Charcoal
  static const Color lightTextSecondary = Color(0xFF4A554F); // Muted Sage
  static const Color lightTextMuted = Color(0xFF86928B); // Light Sage Grey
  
  // Gradients (Soothing organic transitions)
  static const Gradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient accentGradient = LinearGradient(
    colors: [primary, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient guardGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
