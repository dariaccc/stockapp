import 'package:flutter/material.dart';
import 'menu.dart';
import 'radar.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Navigation(), // your bottom nav widget
    );
  }
}
