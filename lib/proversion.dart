import 'package:flutter/material.dart';

class Pro extends StatefulWidget {
  const Pro({super.key});

  @override
  State<Pro> createState() => _ProState();
}

class _ProState extends State<Pro> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("Pro version"), centerTitle: true),
      ),
    );
  }
}
