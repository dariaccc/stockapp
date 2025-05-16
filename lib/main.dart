import 'package:flutter/material.dart';
import '/radar.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("Test home screen"), centerTitle: true),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (context) => Radar()));
          },
          child: Text("Radar"),
        ),
      ),
    );
  }
}
