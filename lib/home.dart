import 'package:flutter/material.dart';
import 'menu.dart';
import 'radar.dart';

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("Home screen"), centerTitle: true),
      ),
    );
  }
}
