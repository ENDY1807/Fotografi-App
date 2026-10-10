import 'package:flutter/material.dart';

class AppTheme {
  static const Color bgDark = Color(0xFF0B0F19);
  static const Color surfaceDark = Color(0xFF151D2F);
  static const Color cardBorder = Color(0xFF23314D);
  static const Color accentGold = Color(0xFFF59E0B);
  static const Color accentGlow = Color(0x33F59E0B);
  
  static const Color textLight = Color(0xFFF8FAFC);
  static const Color textMuted = Color(0xFF94A3B8);

  // Status Curation Colors
  static const Color statusRaw = Color(0xFF64748B);
  static const Color statusCurated = Color(0xFF0284C7);
  static const Color statusEdited = Color(0xFFD97706);
  static const Color statusFinal = Color(0xFF10B981);

  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'raw': return statusRaw;
      case 'curated': return statusCurated;
      case 'edited': return statusEdited;
      case 'final': return statusFinal;
      default: return textMuted;
    }
  }

  static String getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'raw': return 'RAW / Burst';
      case 'curated': return 'Lolos Seleksi';
      case 'edited': return 'Color Graded';
      case 'final': return 'Dokumentasi Resmi';
      default: return status.toUpperCase();
    }
  }

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bgDark,
    primaryColor: accentGold,
    cardColor: surfaceDark,
    fontFamily: 'Roboto',
    colorScheme: const ColorScheme.dark(
      primary: accentGold,
      secondary: accentGold,
      surface: surfaceDark,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: bgDark,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: textLight,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
      iconTheme: IconThemeData(color: textLight),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentGold,
        foregroundColor: Colors.black,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
      ),
    ),
  );
}
