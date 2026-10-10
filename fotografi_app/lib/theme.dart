import 'package:flutter/material.dart';

class AppTheme {
  // Understated Luxury Minimalist Palette (No loud neon)
  static const Color bgDark = Color(0xFF0D0F14);
  static const Color surfaceDark = Color(0xFF141720);
  static const Color cardDark = Color(0xFF181C26);
  static const Color cardBorder = Color(0xFF222634);
  
  // Champagne Brass / Titanium Gold Accent (Muted, expensive feel)
  static const Color accentGold = Color(0xFFC5A880);
  static const Color accentGoldSoft = Color(0x1FC5A880);
  
  static const Color textLight = Color(0xFFE2E6EF);
  static const Color textMuted = Color(0xFF8E96A6);
  static const Color textDim = Color(0xFF5A6272);

  // Muted Sophisticated Status Colors (Not glowing neon)
  static const Color statusRaw = Color(0xFF5C6577);
  static const Color statusCurated = Color(0xFF3A698A);
  static const Color statusEdited = Color(0xFF9B7038);
  static const Color statusFinal = Color(0xFF356D55);
  
  static const Color danger = Color(0xFF9B3B3B);

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
    cardColor: cardDark,
    fontFamily: 'Roboto',
    colorScheme: const ColorScheme.dark(
      primary: accentGold,
      secondary: accentGold,
      surface: surfaceDark,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: surfaceDark,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: textLight,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      ),
      iconTheme: IconThemeData(color: textLight),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentGold,
        foregroundColor: const Color(0xFF0E1015),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
      ),
    ),
  );
}
