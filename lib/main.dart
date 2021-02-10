import 'package:expense_app/screens/add_expense.dart';
import 'package:expense_app/screens/expense_details.dart';
import 'package:expense_app/screens/expenses.dart';
import 'package:expense_app/screens/sign_in.dart';
import 'package:expense_app/screens/sign_up.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
      ),
      initialRoute: 'Sign In',
      routes: {
        'Sign In': (context) => SignInScreen(),
        'Sign Up': (context) => SignUpScreen(),
        'Expenses': (context) => Expenses(),
        'Expense Details': (context) => ExpenseDetails(),
        'Add Expense': (context) => AddExpense(),
      },
    );
  }
}
