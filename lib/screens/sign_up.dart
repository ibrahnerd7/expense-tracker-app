import 'dart:convert';

import 'package:expense_app/models/User.dart';
import 'package:expense_app/screens/sign_in.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  File _image;
  final picker = ImagePicker();
  bool isSubmitting = false;

  final userNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected');
      }
    });
  }

  Future<String> uploadImageToFirebase(BuildContext context) async {
    String userImageUrl = "";
    String fileName = basename(_image.path);
    StorageReference firebaseStorageRef =
        FirebaseStorage.instance.ref().child('uploads/$fileName');
    StorageUploadTask uploadTask = firebaseStorageRef.putFile(_image);
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    var imageUrl = taskSnapshot.ref.getDownloadURL().then(
          (value) => userImageUrl = value,
        );
    var url = await imageUrl;
    return url;
  }

  @override
  void dispose() {
    userNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void collectUserInput(
      String userName, String email, String picture, String password) async {
    User user = await signInUser(userName, email, picture, password);
    if (user != null) {
      Get.to(SignInScreen());
    }
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
      Get.snackbar('Success', "User registered successfully");

      return User.fromJson(jsonDecode(response.body));
    } else {
      Get.snackbar('Error', "Failed to register user");
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
            margin: EdgeInsets.only(top: 42, right: 16, left: 16),
            child: Text(
              "Sign Up",
              textAlign: TextAlign.start,
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 16, right: 16),
            child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 16.0),
                      child: Text(
                        'Profile picture',
                        style: TextStyle(fontSize: 17, color: Colors.black45),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.all(Radius.circular(10.0))),
                      child: _image == null
                          ? Text('Select an image')
                          : Image.file(
                              _image,
                              width: 200,
                              height: 100,
                            ),
                    ),
                    OutlineButton(
                      child: Text(
                        "Upload image",
                        style: TextStyle(fontSize: 20.0),
                      ),
                      highlightedBorderColor: Colors.teal,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      onPressed: getImage,
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
                    SizedBox(
                      height: 32,
                    ),
                    isSubmitting
                        ? CircularProgressIndicator()
                        : Row(
                            children: [
                              Expanded(
                                child: FlatButton(
                                  child: Text(
                                    'Create Account',
                                    style: TextStyle(fontSize: 22.0),
                                  ),
                                  color: Colors.blueAccent,
                                  textColor: Colors.white,
                                  onPressed: () async {
                                    setState(() {
                                      isSubmitting = true;
                                    });

                                    if (_formKey.currentState.validate()) {
                                      String pictureUrl =
                                          await uploadImageToFirebase(context);
                                      collectUserInput(
                                          userNameController.text,
                                          emailController.text,
                                          pictureUrl,
                                          passwordController.text);
                                    }
                                  },
                                ),
                              )
                            ],
                          ),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            child: Text(
                              "Already have an account? Sign In here",
                              style: TextStyle(fontSize: 17.0),
                            ),
                            onPressed: () {
                              Navigator.pushNamed(context, "Sign In");
                            },
                          ),
                        )
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
