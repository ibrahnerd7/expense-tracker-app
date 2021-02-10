import 'dart:convert';
import 'dart:io';

import 'package:expense_app/models/Expense.dart';
import 'package:expense_app/screens/expenses.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';

class AddExpense extends StatefulWidget {
  @override
  _AddExpenseState createState() => _AddExpenseState();
}

class _AddExpenseState extends State<AddExpense> {
  final _storage = FlutterSecureStorage();
  final _formKey = GlobalKey<FormState>();

  bool isSubmmiting = false;
  File _image;
  final picker = ImagePicker();

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final pictureController = TextEditingController();
  final amountController = TextEditingController();

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
    titleController.dispose();
    descriptionController.dispose();
    pictureController.dispose();
    amountController.dispose();
    super.dispose();
  }

  void collectUserInput(
      String title, String description, String amount, String imageUrl) async {
    Expense expense = await addExpense(title, description, amount, imageUrl);
    if (expense != null) {
      Get.snackbar('Success', "Expense added successfully");
      Get.to(Expenses());
    }
    setState(() {
      isSubmmiting = false;
    });
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
    if (response.statusCode == 200) {
      return Expense.fromJson(jsonDecode(response.body));
    } else {
      Get.snackbar('Error', "Failed to add expense");
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
              crossAxisAlignment: CrossAxisAlignment.start,
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
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 16.0),
                          child: Text(
                            'Photo',
                            style:
                                TextStyle(fontSize: 17, color: Colors.black45),
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
                        isSubmmiting
                            ? CircularProgressIndicator()
                            : Container(
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
                                    onPressed: () async {
                                      if (_formKey.currentState.validate()) {
                                        setState(() {
                                          isSubmmiting = true;
                                        });
                                        String pictureUrl =
                                            await uploadImageToFirebase(
                                                context);
                                        collectUserInput(
                                            titleController.text,
                                            descriptionController.text,
                                            amountController.text,
                                            pictureUrl);
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
