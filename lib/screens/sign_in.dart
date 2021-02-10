import 'dart:convert';

import 'package:expense_app/models/User.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final userNameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    userNameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void collectUserInput(String userName, String password) async {
    User user = await signInUser(userName, password);
    print(user.token);
  }

  Future<User> signInUser(String userName, String password) async {
    final response = await http.post(
        'https://guarded-basin-78853.herokuapp.com/users/authenticate',
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(
            <String, String>{'userName': userName, 'password': password}),
    );
    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to authenticate');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                          keyboardType: TextInputType.emailAddress,
                          controller: userNameController,
                          decoration: InputDecoration(labelText: "Email"),
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter some email address';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: passwordController,
                          keyboardType: TextInputType.visiblePassword,
                          decoration: InputDecoration(labelText: "Password"),
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter some password';
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
                                'Sign In',
                                style: TextStyle(fontSize: 22.0),
                              ),
                              color: Colors.blueAccent,
                              textColor: Colors.white,
                              onPressed: () {
                                if (_formKey.currentState.validate()) {
                                  collectUserInput(userNameController.text,
                                      passwordController.text);
                                }
                              },
                            ),
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          margin: EdgeInsets.only(top: 32),
                          child: Expanded(
                            child: TextButton(
                              child: Text(
                                "Don't have an account? Create here",
                                style: TextStyle(fontSize: 17.0),
                              ),
                              onPressed: () {
                                print('Go to create account');
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
