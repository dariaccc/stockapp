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
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Image(image: AssetImage('assets/images/logo-test.png')),
              SizedBox(height: 50),
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Color(0xFF1F2937),
                ),
                height: 400,
                width: 300,
                child: Column(
                  children: [
                    Text(
                      "LOGIN",
                      style: TextStyle(
                        color: Color(0xFFFFFFFF),
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 50),
                    RawMaterialButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => Navigation()),
                        );
                      },
                      fillColor: Color(0xFF111827),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: Colors.white, // 👈 your border color
                          width: 2,
                        ),
                      ),
                      constraints: BoxConstraints.tightFor(
                        width: 120,
                        height: 40,
                      ),
                      child: Text(
                          "Login",
                          style: TextStyle(
                            color: Color(0xFFFFFFFF),
                            fontSize: 15,),
                      ),
                    ),
                    Text(
                        "NO ACCOUNT? REGISTER NOW",
                        style: TextStyle(color: Color(0x80FFFFFF),
                        fontSize: 10
                        ),
                    ),
                    SizedBox(height: 10,),
                    Text(
                      "Administrator Login",
                      style: TextStyle(color: Color(0x80FFFFFF),
                          fontSize: 10
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

      ),
    );
  }
}
