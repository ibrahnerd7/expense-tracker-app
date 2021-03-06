import 'dart:convert';
import 'package:expense_app/models/User.dart';
import 'package:expense_app/screens/expenses.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();

  bool isSubmitting = false;
  final _storage = FlutterSecureStorage();

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
    if (user.token != null) {
      saveAuthToken(user.token);
      Get.to(Expenses());
    }
    setState(() {
      isSubmitting = false;
    });
    userNameController.text = '';
    passwordController.text = '';
  }

  void saveAuthToken(String authToken) async {
    final String key = "authToken";
    final String value = authToken;

    await _storage.write(key: key, value: value);
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
      Get.snackbar("Error", "Failed to authenticate user");
      setState(() {
        isSubmitting = false;
      });
      throw Exception('Failed to authenticate');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(left: 16, top: 42, right: 16),
            child: Text(
              "Sign In",
              textAlign: TextAlign.start,
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 16, right: 16),
            child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
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
                      controller: passwordController,
                      keyboardType: TextInputType.visiblePassword,
                      decoration: InputDecoration(
                        labelText: "Password",
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter some password';
                        }
                        return null;
                      },
                    ),
                    SizedBox(
                      height: 32,
                    ),
                    isSubmitting
                        ? CircularProgressIndicator()
                        : Row(children: [
                            Expanded(
                              child: FlatButton(
                                child: Text(
                                  'Sign In',
                                  style: TextStyle(fontSize: 22.0),
                                ),
                                color: Colors.blueAccent,
                                textColor: Colors.white,
                                onPressed: () {
                                  if (_formKey.currentState.validate()) {
                                    setState(() {
                                      isSubmitting = true;
                                    });
                                    collectUserInput(userNameController.text,
                                        passwordController.text);
                                  }
                                },
                              ),
                            ),
                          ]),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            child: Text(
                              "Don't have an account? Create here",
                              style: TextStyle(fontSize: 17.0),
                            ),
                            onPressed: () {
                              Navigator.pushNamed(context, "Sign Up");
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                )),
          )
        ],
      ),
    );
  }
}
