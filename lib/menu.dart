import 'package:flutter/material.dart';
import 'theme.dart';

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  String? selectedLanguage;
  final TextEditingController _controller = TextEditingController();

  final List languages = [
    "German(DE)",
    "English(UK)",
    "French(FR)",
    "Spanish(ES)",
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SafeArea(
        child: Column(
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
                color: Color(0xFF172033), //background colour for the whole footer
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: MaterialButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Icon(Icons.close, color: Colors.white),
                      ),
                    ),
                    Container(
                      width: 280,
                      height: 38,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Color(0xFFFFFFFF)),
                        color: Color(0xFF111827),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: DefaultTextStyle(
                          style: TextStyle(
                            color: Color(0xFFFFFFFF),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          child: Text("Home", textAlign: TextAlign.center),
                        ),
                      ), //home
                    ),

                    SizedBox(height: 15),

                    Container(
                      width: 280,
                      height: 38,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Color(0xFFFFFFFF)),
                        color: Color(0xFF111827),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: DefaultTextStyle(
                          style: TextStyle(
                            color: Color(0xFFFFFFFF),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          child: Text("Radar", textAlign: TextAlign.center),
                        ),
                      ),
                      //radar
                    ),

                    SizedBox(height: 15),

                    Container(
                      width: 280,
                      height: 38,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Color(0xFFFFFFFF)),
                        color: Color(0xFF111827),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: DefaultTextStyle(
                          style: TextStyle(
                            color: Color(0xFFFFFFFF),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          child: Text(
                            "Purchase PRO",
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      //PRO
                    ),

                    SizedBox(height: 15),

                    Container(
                      width: 280,
                      height: 38,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Color(0xFFFFFFFF)),
                        color: Color(0xFFEF4444), //red background
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: DefaultTextStyle(
                          style: TextStyle(
                            color: Color(0xFFFFFFFF),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          child: Text("Log Out", textAlign: TextAlign.center),
                        ),
                      ),
                      //logout
                    ),

                    SizedBox(height: 15),

                    Container(
                      width: 280,
                      height: 38,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Color(0xFFFFFFFF)),
                        color: Color(0xFFFBBD23), //yellow background
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: DefaultTextStyle(
                          style: TextStyle(
                            color: Color(0xFFFFFFFF),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          child: Text("Dashboard", textAlign: TextAlign.center),
                        ),
                      ),
                      //dashboard
                    ),

                    SizedBox(height: 20),

                   Material(
                     color: Colors.transparent,
                     child: Container(
                          width: 280,
                          height: 45,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Color(0xFF1F2937), //background grey-blue
                          ),
                          child: DropdownButtonHideUnderline(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 30),
                          child: DropdownButton<String>(
                            value: selectedLanguage,
                            hint: Text(
                              "Language",
                              style: TextStyle(color: Colors.white),
                            ),
                            dropdownColor: Color(0xFF1F2937), // menu bg
                            items:
                                languages.map((language) {
                                  final isSelected =
                                      language == selectedLanguage;
                                  return DropdownMenuItem<String>(
                                    value: language,
                                      child: Text(
                                        language,
                                        style: TextStyle(color: Colors.white,
                                        fontSize: 16),
                                      ),
                                  );
                                }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedLanguage = value;
                              });
                            },
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        ),
                      ),
                      ),

                    //dropdown lang
                    SizedBox(height: 15),

                    Container(
                      width: 280,
                      height: 45,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Color(0xFF4F46E5),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 60),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(Icons.pin_drop, color: Colors.white),
                            DefaultTextStyle(
                              style: TextStyle(
                                color: Color(0xFFFFFFFF),
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              child: Text(
                                "Germany",
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 10),

                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 30),
                      child: DefaultTextStyle(
                        style: TextStyle(color: Color(0xFFFFFFFF), fontSize: 8),
                        child: Text(
                          "VANTYX is not a registered broker-dealer or "
                          "investment advisor. Trading involves risk and may "
                          "result in financial loss. Market data is provided for "
                          "informational purposes only and is not intended for trading"
                          " or investment advice. Past performance does not guarantee "
                          "future results. Always do your own research before making "
                          "financial decisions..",
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),

                    //SizedBox(height: 10),

                    //Spacer(), // pushes content above upwards
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 10,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Image(
                            height: 35,
                            image: AssetImage('assets/images/logo-test.png'),
                          ),
                          Container(
                            width: 70,
                            height: 30,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: Color(0xFFFFFFFF),
                            ),
                            child: SegmentedButton<ThemeMode>(
                              segments: [
                              ButtonSegment(value: ThemeMode.light, label: Text("L")),
                              ButtonSegment(value: ThemeMode.dark, label: Text("D")),
                            ], selected: {},
                            onSelectionChanged: (p0) {},)
                          ),
                        ],
                      ),
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
