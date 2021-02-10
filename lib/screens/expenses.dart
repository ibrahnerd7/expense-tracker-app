import 'dart:convert';
import 'dart:io';

import 'package:expense_app/models/Expense.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Expenses extends StatefulWidget {
  @override
  _ExpensesState createState() => _ExpensesState();
}

class _ExpensesState extends State<Expenses> {
  final _storage = FlutterSecureStorage();
  Future<List<Expense>> futureExpenses;

  Future<List<Expense>> fetchExpenses() async {
    final String authToken = await fetchAuthToken();
    List<Expense> futureExpenses = [];

    final response = await http.get(
      'https://guarded-basin-78853.herokuapp.com/expenses',
      headers: <String, String>{
        HttpHeaders.authorizationHeader: 'Bearer $authToken',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> values = new List<dynamic>();
      values = json.decode(response.body);
      print(values);
      if (values.length > 0) {
        for (int i = 0; i < values.length; i++) {
          if(values[i]!=null){
            Map<String,dynamic> map=values[i];
            futureExpenses.add(Expense.fromJson(map));
            debugPrint('Id-------${map['id']}');
          }
        }
      }

      return futureExpenses;
    } else {
      throw new Exception('Failed to fetch expenses');
    }
  }

  Future<String> fetchAuthToken() async {
    final String key = "authToken";
    String value;

    value = await _storage.read(key: key);
    return value;
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
