import 'package:flutter/material.dart';

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SafeArea(
        //backgroundColor: Color(0xFF1F2937),
        //body: SafeArea(
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.top,
          //crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              //see-through top of the menu
              width: MediaQuery.of(context).size.width,
              height: 200,
              color: Color(0x801F2937),
            ),
            Expanded(
              child: Container(
                width: MediaQuery.of(context).size.width,
                color: Color(0xFF1F2937),
                child: Column(
                  children: [
                    Align(
                    alignment: Alignment.topRight,
                      child:
                        MaterialButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Icon(Icons.close, color: Colors.white),
                        ),
                    ),
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
            ),
          ],
        ),
      ),
      //),
    );
  }
}
