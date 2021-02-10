import 'dart:convert';
import 'dart:io';

import 'package:expense_app/models/Expense.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AddExpense extends StatefulWidget {
  @override
  _AddExpenseState createState() => _AddExpenseState();
}

class _AddExpenseState extends State<AddExpense> {
  final _storage = FlutterSecureStorage();
  final _formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final pictureController = TextEditingController();
  final amountController = TextEditingController();
  final imageUrlController = TextEditingController();

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    pictureController.dispose();
    amountController.dispose();
    imageUrlController.dispose();
    super.dispose();
  }

  void collectUserInput(
      String title, String description, String amount, String imageUrl) async {
    Expense expense = await addExpense(title, description, amount, imageUrl);
  }

  Future<String> fetchAuthToken() async {
    final String key = "authToken";
    String value;

    value = await _storage.read(key: key);
    return value;
  }

  Future<Expense> addExpense(
      String title, String description, String amount, String imageUrl) async {
    final String authToken = await fetchAuthToken();

    final response = await http.post(
      'https://guarded-basin-78853.herokuapp.com/expenses/create',
      headers: <String, String>{
        HttpHeaders.authorizationHeader: 'Bearer $authToken',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "title": title,
        "description": description,
        "amount": amount,
        "imageUrl": imageUrl
      }),
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      return Expense.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to add expense');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add expense"),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.only(top: 24, bottom: 16),
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TextFormField(
                          keyboardType: TextInputType.text,
                          controller: titleController,
                          decoration: InputDecoration(labelText: "Title"),
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter some title';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: descriptionController,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(labelText: "Description"),
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter some description';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: amountController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(labelText: "Amount"),
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter some amount';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: imageUrlController,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(labelText: "Picture"),
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter some image url';
                            }
                            return null;
                          },
                        ),
                        Container(
                          width: double.infinity,
                          margin: EdgeInsets.only(top: 32),
                          child: Expanded(
                            child: FlatButton(
                              child: Text(
                                'Save',
                                style: TextStyle(fontSize: 22.0),
                              ),
                              color: Colors.blueAccent,
                              textColor: Colors.white,
                              onPressed: () {
                                if (_formKey.currentState.validate()) {
                                  collectUserInput(
                                      titleController.text,
                                      descriptionController.text,
                                      amountController.text,
                                      imageUrlController.text);
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
