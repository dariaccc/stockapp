import 'package:flutter/material.dart';
import 'menu.dart';
import 'radar.dart';

class Dashboard extends StatefulWidget {
  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("Dashboard"), centerTitle: true),
      ),
    );
  }
}
