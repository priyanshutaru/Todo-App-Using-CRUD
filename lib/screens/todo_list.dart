// ignore_for_file: prefer_const_constructors, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:todo_api/screens/add_task.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;

class ToDoListPage extends StatefulWidget {
  const ToDoListPage({super.key});

  @override
  State<ToDoListPage> createState() => _ToDoListPageState();
}

class _ToDoListPageState extends State<ToDoListPage> {
  bool isLoading = true;
  List items = [];
  @override
  void initState() {
    super.initState();
    fetchTodo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text("Todo List"),
      ),
      body: Visibility(
        visible: isLoading,
        child: Center(
          child: CircularProgressIndicator(),
        ),
        replacement: RefreshIndicator(
          onRefresh: fetchTodo,
          child: Visibility(
            visible: items.isNotEmpty,
            replacement: Center(
              child: Text(
                "No Todo Item",
                style: TextStyle(fontSize: 20),
              ),
            ),
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index] as Map;
                final id = item['_id'] as String;
                return Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text('${index + 1}'),
                      ),
                      title: Text(item['title']),
                      subtitle: Text(item['description']),
                      trailing: PopupMenuButton(
                        onSelected: (value) {
                          if (value == 'edit') {
                            //open the edit page
                            navigateEditPage(item);
                          } else if (value == 'delete') {
                            //delete and refresh page
                            deleteById(id);
                          }
                        },
                        itemBuilder: (context) {
                          return [
                            PopupMenuItem(
                              child: Text("Edit"),
                              value: 'edit',
                            ),
                            PopupMenuItem(
                              child: Text("Delete"),
                              value: 'delete',
                            ),
                          ];
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.grey,
        onPressed: navigateToaddPage,
        // () {
        //   Navigator.push(
        //       context, MaterialPageRoute(builder: (context) => AddTaskPage()));
        // },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  Future<void> fetchTodo() async {
    setState(() {
      isLoading = true;
    });
    final respons = await http.get(
      Uri.parse('http://api.nstack.in/v1/todos?page=1&limit=15'),
    );

    if (respons.statusCode == 200) {
      final json = jsonDecode(respons.body) as Map;
      final result = json['items'] as List;
      setState(() {
        items = result;
      });
    } else {}
    setState(() {
      isLoading = false;
    });
    // print(respons.statusCode);
    // print(respons.body);
  }

  Future<void> deleteById(String id) async {
    //first we delete the item

    final deleteresponse = await http.delete(
      Uri.parse('http://api.nstack.in/v1/todos/$id'),
    );
    if (deleteresponse.statusCode == 200) {
      final filtered = items.where((element) => element['_id'] != id).toList();
      setState(() {
        items = filtered;
      });
      //remove from the list
    } else {
      //show the error
    }
  }

  Future<void> navigateToaddPage() async {
    final route = MaterialPageRoute(
      builder: (context) => AddTaskPage(),
    );
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetchTodo();
  }

  Future<void> navigateEditPage(Map item) async {
    final route = MaterialPageRoute(
      builder: (context) => AddTaskPage(todo: item),
    );
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetchTodo();
  }
}
