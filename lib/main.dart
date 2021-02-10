import 'package:expense_app/screens/expenses.dart';
import 'package:expense_app/screens/sign_in.dart';
import 'package:expense_app/screens/sign_up.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      initialRoute: 'Sign In',
      routes: {
        'Sign In':(context)=>SignInScreen(),
        'Sign Up':(context)=>SignUpScreen(),
        'Expenses':(context)=>Expenses()
      },
    );
  }
}

