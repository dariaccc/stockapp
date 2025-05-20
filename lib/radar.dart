import 'package:flutter/material.dart';

class Radar extends StatefulWidget {
  const Radar({super.key});

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

                Stack(
                  alignment: Alignment.bottomLeft,
                  children: [
                    Container(
                      height: 500,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(
                            "assets/images/news-placeholder.png",
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 150,
                      color: Color(0x90111827),
                    ),
                    Container(
                      margin: EdgeInsets.all(10),
                      //width: MediaQuery.of(context).size.width - 20,
                      height: 120,
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Color(0xFF111827),
                      ),
                      child: Column(
                        children: [
                          Text(
                              "News title that is quite long, so that it is at least 2-3 rows",
                              style: TextStyle(
                                color: Color(0xFFFFFFFF),
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.left,
                          ),
                          Text(
                              "Some more information, lorem ipsum and more text and more text"
                                  "that will maybe be a real news article...",
                              style: TextStyle(
                                color: Color(0x80FFFFFF),
                                fontSize: 10,
                              ),
                              textAlign: TextAlign.left,
                          ),
                        ]
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 30),

                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Color(0xFF1F2937),
                  ),
                  height: 300,
                  width: 350,
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Color(0xFF4F46E5),
                        ),
                        child: Text(
                          "Top performers today",
                          style: TextStyle(
                            color: Color(0xFFFFFFFF),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: 30),

                      Container(
                        width: 320,
                        height: 55,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Color(0xFFFFFFFF)),
                          color: Color(0xFF111827),
                        ),
                        //stock information
                      ),

                      SizedBox(height: 15),

                      Container(
                        width: 320,
                        height: 55,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Color(0xFFFFFFFF)),
                          color: Color(0xFF111827),
                        ),
                        //stock information
                      ),

                      SizedBox(height: 15),

                      Container(
                        width: 320,
                        height: 55,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Color(0xFFFFFFFF)),
                          color: Color(0xFF111827),
                        ),
                        //stock information
                      ),
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
                  width: 350,
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Color(0xFFFFFFFF),
                        ),
                        child: Text(
                          "Worst performers today",
                          style: TextStyle(
                            color: Color(0xFF1F2937),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: 30),

                      Container(
                        width: 320,
                        height: 55,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Color(0xFFFFFFFF)),
                          color: Color(0xFF111827),
                        ),
                        //stock information
                      ),

                      SizedBox(height: 15),

                      Container(
                        width: 320,
                        height: 55,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Color(0xFFFFFFFF)),
                          color: Color(0xFF111827),
                        ),
                        //stock information
                      ),

                      SizedBox(height: 15),

                      Container(
                        width: 320,
                        height: 55,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Color(0xFFFFFFFF)),
                          color: Color(0xFF111827),
                        ),
                        //stock information
                      ),
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
