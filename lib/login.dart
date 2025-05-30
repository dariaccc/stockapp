import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'navbar.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {

    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Scaffold(
        backgroundColor: colorScheme.primary,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Image(width: 300, image: AssetImage('assets/images/logo-test.png')),
              SizedBox(height: 50),
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: colorScheme.secondary,
                ),
                height: 400,
                width: 300,
                child: Column(
                  children: [

                    Text(
                      "LOGIN",
                      style: TextStyle(
                        color: colorScheme.onPrimary,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 30),

                    //customer ID input field
                    Text(
                      "Customer ID",
                      style: TextStyle(
                        color: colorScheme.onPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    TextField(
                      cursorColor: Color(0xFF4F46E5),
                      style: TextStyle(color: colorScheme.onPrimary),
                      decoration: InputDecoration(
                        isDense: true,
                        //contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        filled: true,
                        fillColor: colorScheme.primary,
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent),
                        ),
                      ),
                    ),

                    SizedBox(height: 20,),

                    //PIN input field
                    Text(
                      "PIN",
                      style: TextStyle(
                        color: colorScheme.onPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    PinCodeTextField(
                      appContext: context,
                      length: 6,
                      cursorColor: Color(0xFF4F46E5),
                      textStyle: TextStyle(color: colorScheme.onPrimary),
                      enableActiveFill: true,
                      pinTheme: PinTheme(
                        shape: PinCodeFieldShape.box,
                        borderRadius: BorderRadius.circular(8),
                        fieldHeight: 50,
                        fieldWidth: 40,
                        activeColor: Color(0xFF4F46E5),
                        inactiveColor: colorScheme.primary,
                        selectedColor: Colors.white,
                        activeFillColor: colorScheme.primary,    // filled when typing
                        inactiveFillColor: colorScheme.primary, // initial state
                        selectedFillColor: colorScheme.primary,
                      ),
                    ),

                    SizedBox(height: 20),

                    //login-button
                    RawMaterialButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => Navigation()),
                        );
                      },
                      fillColor: colorScheme.tertiary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: colorScheme.onPrimary,
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
                            color: colorScheme.onPrimary,
                            fontSize: 15,),
                      ),
                    ),

                    SizedBox(height: 5,),

                    Text(
                        "NO ACCOUNT? REGISTER NOW",
                        style: TextStyle(color: Color(0x80FFFFFF),
                        fontSize: 10
                        ),
                    ),
                    SizedBox(height: 5,),
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

    );
  }
}
