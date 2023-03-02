// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;

class AddTaskPage extends StatefulWidget {
  final Map? todo;
  const AddTaskPage({super.key, this.todo});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descryptionController = TextEditingController();

  bool isEdit = false;
  @override
  void initState() {
    super.initState();
    final todo = widget.todo;
    if (todo != null) {
      isEdit = true;
      final title = todo['title'];
      final descryption = todo['description'];
      titleController.text = title;
      descryptionController.text = descryption;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          isEdit ? 'Edit Todo' : 'Add Todo',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            SizedBox(
              height: 3,
            ),
            TextField(
              controller: titleController,
              minLines: 1,
              maxLines: 1,
              decoration: InputDecoration(hintText: "Title"),
            ),
            SizedBox(
              height: 20,
            ),
            TextField(
              controller: descryptionController,
              minLines: 5,
              maxLines: 8,
              decoration: InputDecoration(hintText: "Descryption"),
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: isEdit ? updateData : submitData,
              child: Text(
                isEdit ? 'Update' : 'Submit',
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> updateData() async {
    final todo = widget.todo;
    if (todo == null) {
      print("Please Update Somethings");
      return;
    }
    final id = todo['_id'];
    // final isCompleated = todo['is_completed'];

    final title = titleController.text;
    final descryption = descryptionController.text;
    final body = {
      "title": title,
      "description": descryption,
      "is_completed": false,
    };
    final response = await http.put(
      Uri.parse(
        'http://api.nstack.in/v1/todos/$id',
      ),
      body: jsonEncode(body),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      titleController.text = '';
      descryptionController.text = '';

      print("Creation Succes");
      showSuccessMessage("Successfully Updated");
      // print(response.body);
    } else {
      print("Creation faild");
      showErrorMessage("Updation Faild");
      // print(response.body);
    }
  }

  Future<void> submitData() async {
    print("button clicked");
    // data part of the api
    final title = titleController.text;
    final descryption = descryptionController.text;
    final body = {
      "title": title,
      "description": descryption,
      "is_completed": false,
    };

    //  submit data to the server

    final response = await http.post(
      Uri.parse(
        'http://api.nstack.in/v1/todos',
      ),
      body: jsonEncode(body),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 201) {
      titleController.text = '';
      descryptionController.text = '';

      print("Creation Succes");
      showSuccessMessage("Creation Succes");
      // print(response.body);
    } else {
      print("Creation faild");
      showErrorMessage("Creation Faild");
      // print(response.body);
    }
  }

  void showSuccessMessage(String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void showErrorMessage(String message) {
    final snackBar = SnackBar(
      backgroundColor: Colors.red,
      content: Text(
        message,
        style: TextStyle(color: Colors.white),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
