import 'package:flutter/material.dart';
import 'package:stock_app/proversion.dart';
import 'package:stock_app/radar.dart';
import 'dashboard.dart';
import 'home.dart';
import 'login.dart';
import 'main.dart';
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
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return SafeArea(
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
              color: colorScheme.primary, //background colour for the whole footer
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: MaterialButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Icon(Icons.close, color: colorScheme.onPrimary),
                    ),
                  ),

                  //home-button
                  RawMaterialButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => Home()),
                      );
                    },
                    fillColor: colorScheme.secondary, //yellow
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: colorScheme.onPrimary,
                      ),
                    ),
                    constraints: BoxConstraints.tightFor(
                      width: 280,
                      height: 38,
                    ),
                    child: DefaultTextStyle(
                      style: TextStyle(
                        color: colorScheme.onPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text("Home", textAlign: TextAlign.center),
                      ),
                    ),
                  ),

                  SizedBox(height: 5),

                  RawMaterialButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => Radar()),
                      );
                    },
                    fillColor: colorScheme.secondary, //yellow
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: colorScheme.onPrimary,
                      ),
                    ),
                    constraints: BoxConstraints.tightFor(
                      width: 280,
                      height: 38,
                    ),
                    child: DefaultTextStyle(
                      style: TextStyle(
                        color: colorScheme.onPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text("Radar", textAlign: TextAlign.center),
                      ),
                    ),
                  ),

                  SizedBox(height: 5),

                  RawMaterialButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => Pro()),
                      );
                    },
                    fillColor: colorScheme.secondary, //yellow
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: colorScheme.onPrimary,
                      ),
                    ),
                    constraints: BoxConstraints.tightFor(
                      width: 280,
                      height: 38,
                    ),
                    child: DefaultTextStyle(
                      style: TextStyle(
                        color: colorScheme.onPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text("Purchase PRO", textAlign: TextAlign.center),
                      ),
                    ),
                  ),

                  SizedBox(height: 5),

                  RawMaterialButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => Login()),
                      );
                    },
                    fillColor: Color(0xFFEF4444),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: colorScheme.onPrimary,
                      ),
                    ),
                    constraints: BoxConstraints.tightFor(
                      width: 280,
                      height: 38,
                    ),
                    child: DefaultTextStyle(
                      style: TextStyle(
                        color: Color(0xFFFFFFFF),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text("Log Out", textAlign: TextAlign.center),
                      ),
                      ),
                  ),

                  SizedBox(height: 5),

                  RawMaterialButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => Dashboard()),
                      );
                    },
                    fillColor: Color(0xFFFBBD23), //yellow
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: colorScheme.onPrimary,
                      ),
                    ),
                    constraints: BoxConstraints.tightFor(
                      width: 280,
                      height: 38,
                    ),
                    child: DefaultTextStyle(
                      style: TextStyle(
                        color: Color(0xFF000000),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text("Dashboard", textAlign: TextAlign.center),
                      ),
                    ),
                  ),

                  SizedBox(height: 10),

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
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
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
                      color: colorScheme.onSecondary,
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 60),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(Icons.pin_drop, color: Colors.white),
                          DefaultTextStyle(
                            style: TextStyle(
                              color: colorScheme.onPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            child: Text("Germany", textAlign: TextAlign.center),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 10),

                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: DefaultTextStyle(
                      style: TextStyle(color: colorScheme.onPrimary, fontSize: 8),
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
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed:
                                  () => MyApp.of(
                                    context,
                                  ).changeTheme(ThemeMode.light),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.onPrimary,
                              ),
                              child: Text(
                                "Light",
                                style: TextStyle(color: colorScheme.onTertiary),
                              ),
                            ),
                            ElevatedButton(
                              onPressed:
                                  () => MyApp.of(
                                    context,
                                  ).changeTheme(ThemeMode.dark),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.onPrimary,
                              ),
                              child: Text(
                                'Dark',
                                style: TextStyle(color: colorScheme.tertiary),
                              ),
                            ),
                          ],
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
    );
  }
}
