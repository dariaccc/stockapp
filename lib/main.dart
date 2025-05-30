import 'package:flutter/material.dart';
import 'login.dart';
import 'package:stock_app/theme.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: light,
      darkTheme: dark,
      themeMode: ThemeMode.system,
      home: Login(),
    );
  }
}
