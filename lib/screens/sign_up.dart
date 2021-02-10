import 'dart:convert';

import 'package:expense_app/models/User.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final userNameController = TextEditingController();
  final pictureController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    userNameController.dispose();
    pictureController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void collectUserInput(
      String userName, String email, String picture, String password) async {
    User user = await signInUser(userName, email, picture, password);
  }

  Future<User> signInUser(
      String userName, String email, String picture, String password) async {
    final response = await http.post(
      'https://guarded-basin-78853.herokuapp.com/users/register',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'userName': userName,
        'picture': picture,
        'email': email,
        'password': password
      }),
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
                          keyboardType: TextInputType.name,
                          controller: userNameController,
                          decoration: InputDecoration(labelText: "Username"),
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter some username';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: pictureController,
                          decoration: InputDecoration(labelText: "Picture"),
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter some picture';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          controller: emailController,
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
                                'Create Account',
                                style: TextStyle(fontSize: 22.0),
                              ),
                              color: Colors.blueAccent,
                              textColor: Colors.white,
                              onPressed: () {
                                if (_formKey.currentState.validate()) {
                                  collectUserInput(
                                      userNameController.text,
                                      emailController.text,
                                      pictureController.text,
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
                                "Already have an account? Sign In here",
                                style: TextStyle(fontSize: 17.0),
                              ),
                              onPressed: () {
                                Navigator.pushNamed(context, "Sign In");
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
