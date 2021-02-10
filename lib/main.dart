import 'package:expense_app/screens/sign_up.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      initialRoute: 'Sign Up',
      routes: {
        'Sign Up':(context)=>SignUpScreen()
      },
    );
  }
}

