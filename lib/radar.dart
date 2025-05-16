import 'package:flutter/material.dart';
import 'menu.dart';

class Radar extends StatefulWidget {
  @override
  State<Radar> createState() => _RadarState();
}

class _RadarState extends State<Radar> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("Radar"), centerTitle: true),
      ),
    );
  }
}
