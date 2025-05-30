import 'package:flutter/material.dart' hide CarouselController;
import 'package:carousel_slider/carousel_slider.dart';

class Radar extends StatefulWidget {
  const Radar({super.key});

  @override
  State<Radar> createState() => _RadarState();
}

class _RadarState extends State<Radar> {
  @override
  Widget build(BuildContext context) {

    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 10),

                //search bar
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  width: MediaQuery.of(context).size.width - 20,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: colorScheme.onSecondary,
                  ),
                  child: Text("search",
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                    ),
                ),
                ),

                SizedBox(height: 10),

                //stack for carousel
                CarouselSlider(
                  items: [
                    Stack(
                      alignment: Alignment.bottomLeft,
                      children: [
                        Container(
                          height: 500,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(
                                "assets/images/news.png",
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: 150,
                          color: colorScheme.primary.withValues(alpha: 0.7),
                        ),
                        Container(
                          margin: EdgeInsets.all(10),
                          //width: MediaQuery.of(context).size.width - 20,
                          height: 120,
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: colorScheme.tertiary,
                          ),
                          child: Column(
                              children: [
                                Text(
                                  "News title that is quite long, so that it is at least 2-3 rows",
                                  style: TextStyle(
                                    color: colorScheme.onPrimary,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                                Text(
                                  "Some more information, lorem ipsum and more text and more text"
                                      "that will maybe be a real news article...",
                                  style: TextStyle(
                                    color: colorScheme.onPrimary.withValues(alpha: 0.8),
                                    fontSize: 10,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ]
                          ),
                        ),
                      ],
                    ),

                    Stack(
                      alignment: Alignment.bottomLeft,
                      children: [
                        Container(
                          height: 500,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(
                                "assets/images/planet.png",
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: 150,
                          color: colorScheme.primary.withValues(alpha: 0.7),
                        ),
                        Container(
                          margin: EdgeInsets.all(10),
                          //width: MediaQuery.of(context).size.width - 20,
                          height: 120,
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: colorScheme.tertiary,
                          ),
                          child: Column(
                              children: [
                                Text(
                                  "THIS is a picture of a planet",
                                  style: TextStyle(
                                    color: colorScheme.onPrimary,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                                Text(
                                  "Some more information, lorem ipsum and more text and more text"
                                      "that will maybe be a real news article...",
                                  style: TextStyle(
                                    color: colorScheme.onPrimary.withValues(alpha: 0.8),
                                    fontSize: 10,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ]
                          ),
                        ),
                      ],
                    ),

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
                          color: colorScheme.primary.withValues(alpha: 0.7),
                        ),
                        Container(
                          margin: EdgeInsets.all(10),
                          //width: MediaQuery.of(context).size.width - 20,
                          height: 120,
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: colorScheme.tertiary,
                          ),
                          child: Column(
                              children: [
                                Text(
                                  "A different news title",
                                  style: TextStyle(
                                    color: colorScheme.onPrimary,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                                Text(
                                  "And a new text that goes on and on and on and on and on"
                                      "and on and on and on and on...",
                                  style: TextStyle(
                                    color: colorScheme.onPrimary.withValues(alpha: 0.8),
                                    fontSize: 10,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ]
                          ),
                        ),
                      ],
                    ),
                  ],
                  options: CarouselOptions(
                    height: 500,
                    autoPlay: true,
                    enableInfiniteScroll: true,
                    viewportFraction: 1.0,
                  ),
                ),


                SizedBox(height: 30),

                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Color(0xFF000000)),
                    color: colorScheme.secondary,
                  ),
                  height: 300,
                  width: 350,
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: colorScheme.onSecondary,
                        ),
                        child: Text(
                          "Top performers today",
                          style: TextStyle(
                            color: colorScheme.onPrimary,
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
                          border: Border.all(color: colorScheme.onPrimary),
                          color: colorScheme.tertiary,
                        ),
                        //stock information
                      ),

                      SizedBox(height: 15),

                      Container(
                        width: 320,
                        height: 55,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: colorScheme.onPrimary),
                          color: colorScheme.tertiary,
                        ),
                        //stock information
                      ),

                      SizedBox(height: 15),

                      Container(
                        width: 320,
                        height: 55,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: colorScheme.onPrimary),
                          color: colorScheme.tertiary,
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
                    border: Border.all(color: Color(0xFF000000)),
                    color: colorScheme.secondary,
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
                            color: Color(0xFF111827),
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
                          border: Border.all(color: colorScheme.onPrimary),
                          color: colorScheme.tertiary,
                        ),
                        //stock information
                      ),

                      SizedBox(height: 15),

                      Container(
                        width: 320,
                        height: 55,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: colorScheme.onPrimary),
                          color: colorScheme.tertiary,
                        ),
                        //stock information
                      ),

                      SizedBox(height: 15),

                      Container(
                        width: 320,
                        height: 55,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: colorScheme.onPrimary),
                          color: colorScheme.tertiary,
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
    );
  }
}
