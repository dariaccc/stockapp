import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'login.dart';
import 'theme.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: light,
      darkTheme: dark,
      themeMode: _themeMode,
      builder: (context, child) {
        final brightness = Theme.of(context).brightness;

        // this makes clock, battery etc the right color for contrast
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness:
            brightness == Brightness.dark ? Brightness.light : Brightness.dark,
            statusBarBrightness:
            brightness == Brightness.dark ? Brightness.dark : Brightness.light,
          ),
        );

        return child!;
      },
      home: Login(),
    );

  }

  void changeTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }
}
