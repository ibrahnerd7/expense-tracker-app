import 'dart:convert';
import 'dart:io';

import 'package:expense_app/models/User.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<User> futureUser;
  final _storage = FlutterSecureStorage();

  Future<User> fetchUser() async {
    final String authToken = await fetchAuthToken();

    final response = await http.get(
      'https://guarded-basin-78853.herokuapp.com/users/current',
      headers: <String, String>{
        HttpHeaders.authorizationHeader: 'Bearer $authToken',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw new Exception('Failed to fetch current user');
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
    futureUser = fetchUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
      ),
      body: Container(
        child: FutureBuilder<User>(
          future: futureUser,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              User user = snapshot.data;
              return Container(
                margin: EdgeInsets.only(top: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      child: Center(
                        child: CircleAvatar(
                          radius: 60.0,
                          backgroundImage: NetworkImage(user.picture),
                          backgroundColor: Colors.transparent,
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 32, left: 16),
                      child: Text(user.userName),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 32, left: 16),
                      child: Text(user.email),
                    )
                  ],
                ),
              );
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            return CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}
