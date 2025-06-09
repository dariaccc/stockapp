import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData light = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Color(0xFFFFFFFF),
      primary: Color(0xFFFFFFFF),
      onPrimary: Color(0xFF000000),
      secondary: Color(0xFFE4F0FF),
      onSecondary: Color(0xFF94A6CD),
      tertiary: Color(0xFFFFFFFF),
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: Color(0xFFFFFFFF), // background
    brightness: Brightness.light,
    textTheme: TextTheme(
      displayLarge: GoogleFonts.spaceGrotesk(fontSize: 40, fontWeight: FontWeight.bold), // Titles
      titleMedium: GoogleFonts.manrope(fontSize: 20),  // Subheadings
      labelLarge: GoogleFonts.sora(fontSize: 16),      // Buttons
      headlineSmall: GoogleFonts.dmSans(fontSize: 18), // Categories
      bodyMedium: GoogleFonts.inter(fontSize: 16),     // Body
    ),// must match ColorScheme
);

ThemeData dark = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: Color(0xFF111827),
    primary: Color(0xFF111827),
    onPrimary: Color(0xFFFFFFFF),
    secondary: Color(0xFF1F2937),
    onSecondary: Color(0xFF4F46E5),
    tertiary: Color(0xFF111827),
    onTertiary: Color(0xFF000000),
    brightness: Brightness.dark,
  ),
  scaffoldBackgroundColor: Color(0xFF111827),
  brightness: Brightness.dark,
  textTheme: TextTheme(
    displayLarge: GoogleFonts.spaceGrotesk(fontSize: 40, fontWeight: FontWeight.bold), // Titles
    titleMedium: GoogleFonts.manrope(fontSize: 20),  // Subheadings
    labelLarge: GoogleFonts.sora(fontSize: 16),      // Buttons
    headlineSmall: GoogleFonts.dmSans(fontSize: 18), // Categories
    bodyMedium: GoogleFonts.inter(fontSize: 16),     // Body
  ),
);