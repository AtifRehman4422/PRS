import 'package:flutter/material.dart';

/// Central place for all app colors so they can be reused easily.
class AppColors {
  AppColors._();

  // ============== Primary Colors ==============
  /// Main brand color (used in header and bottom navigation).
  static const Color primary = Color(0xFFE30707);

  /// Slightly darker shade of the primary color for gradients.
  static const Color primaryDark = Color(0xFFD20000);

  /// Light shade of primary for backgrounds.
  static const Color primaryLight = Color(0xFFFFEBEE);

  // ============== Background & Surface ==============
  /// Page background behind cards and content.
  static const Color background = Color(0xFFFFF7F5);

  /// Color for the white surfaces like cards and search box.
  static const Color surface = Colors.white;

  // ============== Text Colors ==============
  /// Text color for titles and labels.
  static const Color textPrimary = Colors.black87;

  /// Color for subtle secondary text.
  static const Color textSecondary = Colors.black54;

  // ============== Gradient Colors ==============
  /// Red color for gradients.
  static const Color gradientRed = Colors.red;

  /// Black color for gradients.
  static const Color gradientBlack = Colors.black;

  /// Grey color for gradients.
  static const Color gradientGrey = Colors.grey;

  /// Brown color for gradients.
  static const Color gradientBrown = Color(0xFF795548);

  /// Green color for gradients.
  static const Color gradientGreen = Color(0xFF43A047);

  /// Blue color for gradients.
  static const Color gradientBlue = Color(0xFF1E88E5);

  /// Orange color for gradients.
  static const Color gradientOrange = Color(0xFFFB8C00);

  // ============== Icon Colors ==============
  /// Icon default color.
  static const Color iconDefault = Colors.grey;

  /// Icon dark color.
  static const Color iconDark = Colors.black;

  // ============== Border & Divider ==============
  /// Border color light.
  static const Color borderLight = Color(0xFFE0E0E0);

  /// Divider color.
  static const Color divider = Color(0xFFBDBDBD);

  // ============== Hint & Placeholder ==============
  /// Hint text color.
  static const Color hintText = Color(0xFF9E9E9E);

  /// Placeholder color.
  static const Color placeholder = Color(0xFF757575);

  // ============== Google Button Colors ==============
  static const Color googleRed = Colors.red;
  static const Color googleOrange = Colors.orange;
  static const Color googleGreen = Colors.green;
  static const Color googleBlue = Colors.blue;
}

