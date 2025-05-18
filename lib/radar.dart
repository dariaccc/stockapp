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
        backgroundColor: Color(0xFF111827),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 10),

                Container(
                  padding: EdgeInsets.all(5),
                  width: MediaQuery.of(context).size.width - 20,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Color(0xFFFFFFFF),
                  ),
                  child: Text("search bar placeholder"),
                ),

                SizedBox(height: 10),

                Container(
                  height: 600,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/news-placeholder.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                SizedBox(height: 30),

                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Color(0xFF1F2937),
                  ),
                  height: 300,
                  width: 300,
                  child: Column(
                    children: [
                      Text(
                        "Test",
                        style: TextStyle(
                          color: Color(0xFFFFFFFF),
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: 30),
                    ],
                  ),
                ),

                SizedBox(height: 30),

                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Color(0xFF1F2937),
                  ),
                  height: 300,
                  width: 300,
                  child: Column(
                    children: [
                      Text(
                        "Test",
                        style: TextStyle(
                          color: Color(0xFFFFFFFF),
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: 30),
                    ],
                  ),
                ),
                SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
