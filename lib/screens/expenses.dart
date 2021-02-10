import 'dart:convert';
import 'dart:io';

import 'package:expense_app/models/Expense.dart';
import 'package:expense_app/screens/add_expense.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
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
          if (values[i] != null) {
            Map<String, dynamic> map = values[i];
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
        leading: Container(),
        centerTitle: false,
        title: Text('Expenses'),
      ),
      body: Container(
        child: FutureBuilder<List<Expense>>(
          future: futureExpenses,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  Expense expense = snapshot.data[index];
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(index.toString()),
                    ),
                    title: Text(expense.title),
                    subtitle: Text("Kshs ${expense.amount}"),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => print('delete'),
                    ),
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            return CircularProgressIndicator();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(AddExpense()),
        child: Icon(Icons.add),
      ),
    );
  }
}
