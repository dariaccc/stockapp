import 'package:flutter/material.dart';
import 'menu.dart';

class Login extends StatefulWidget {
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Color(0xFF111827),
        appBar: AppBar(
          backgroundColor: Color(0xFF111827),
          title: Text("Login", style: TextStyle(color: Color(0xFFFFFFFF))),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Color(0xFF1F2937),
              ),
              height: 400,
              width: 300,
              child: Text(
                "data",
                style: TextStyle(
                    color: Color(0xFFFFFFFF),
                    fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => Navigation()),
            );
          },
          child: Text("click"),
        ),
      ),
    );
  }
}
