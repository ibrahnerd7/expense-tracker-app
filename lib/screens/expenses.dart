import 'package:flutter/material.dart';

class Expenses extends StatefulWidget {
  @override
  _ExpensesState createState() => _ExpensesState();
}

class _ExpensesState extends State<Expenses> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expenses'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => print("Go to add expense"),
        child: Icon(Icons.add),
      ),
    );
  }
}
