import 'package:flutter/material.dart';

ThemeData light = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Color(0xFFFFFFFF),
      primary: Color(0xFFFFFFFF),
      secondary: Color(0xFFE4F0FF),
      onSecondary: Color(0xFF94A6CD),
      tertiary: Color(0xFFFFFFFF),
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: Color(0xFFFFFFFF), // set here
    brightness: Brightness.light, // must match ColorScheme
);

ThemeData dark = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: Color(0xFF111827),
    primary: Color(0xFF111827),
    secondary: Color(0xFF1F2937),
    onSecondary: Color(0xFF4F46E5),
    tertiary: Color(0xFF111827),
    brightness: Brightness.dark,
  ),
  scaffoldBackgroundColor: Color(0xFFFFFFFF), // set here
  brightness: Brightness.dark,
);