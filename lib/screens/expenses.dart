import 'dart:convert';

import 'package:expense_app/models/Expense.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Expenses extends StatefulWidget {
  @override
  _ExpensesState createState() => _ExpensesState();
}

class _ExpensesState extends State<Expenses> {
  Future<List<Expense>> futureExpenses;

  Future<List<Expense>> fetchExpenses() async {
    List<Expense> futureExpenses = [];

    final response = await http.get(
      'https://guarded-basin-78853.herokuapp.com/expenses',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    print(response.statusCode);

    if (response.statusCode == 200) {
      Expense expense = Expense.fromJson(jsonDecode(response.body));
      futureExpenses.add(expense);

      return futureExpenses;
    } else {
      throw new Exception('Failed to fetch expenses');
    }
  }

  @override
  void initState() {
    super.initState();
    futureExpenses = fetchExpenses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expenses'),
      ),
      body: Center(
        child: FutureBuilder<List<Expense>>(
          future: futureExpenses,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Text(snapshot.data.length.toString());
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            return CircularProgressIndicator();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => print("Go to add expense"),
        child: Icon(Icons.add),
      ),
    );
  }
}
