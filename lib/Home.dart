import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List _todoList = [];
  Map<String, dynamic> _todoDeleted = Map();
  TextEditingController _todoController = TextEditingController();

  Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/data.json');
  }

  _saveFile() async {
    final file = await _getFile();

    String data = json.encode(_todoList);
    file.writeAsString(data);
  }

  _readFile() async {
    try {
      final file = await _getFile();
      return file.readAsString();
    } catch (e) {
      return null;
    }
  }

  _saveTodo() {
    String todoText = _todoController.text;

    Map<String, dynamic> todo = Map();
    todo['title'] = todoText;
    todo['check'] = false;

    setState(() {
      _todoList.add(todo);
    });

    _saveFile();
    Navigator.pop(context);
    _todoController.text = '';
  }

  Widget _createItemList(context, index) {
    return Dismissible(
        key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
        direction: DismissDirection.endToStart,
        onDismissed: (direction) {
          _todoDeleted = _todoList[index];

          _todoList.removeAt(index);
          _saveFile();

          final snackBar = SnackBar(
            content: Text('Todo removed: ${_todoDeleted['title']}'),
            duration: Duration(seconds: 5),
            action: SnackBarAction(
                label: 'Dissolve',
                onPressed: () {
                  setState(() {
                    _todoList.insert(index, _todoDeleted);
                  });

                  _saveFile();
                }),
          );

          Scaffold.of(context).showSnackBar(snackBar);
        },
        background: Container(
          color: Colors.red,
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(
                Icons.delete,
                color: Colors.white,
              )
            ],
          ),
        ),
        child: CheckboxListTile(
          title: Text(_todoList[index]['title']),
          value: _todoList[index]['check'],
          onChanged: (value) {
            setState(() {
              _todoList[index]['check'] = value;
            });

            _saveFile();
          },
        ));
  }

  @override
  void initState() {
    super.initState();

    _readFile().then((data) {
      setState(() {
        _todoList = json.decode(data);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Todo List'),
          backgroundColor: Colors.black26,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Add Todo'),
                    content: TextField(
                      controller: _todoController,
                      decoration: InputDecoration(labelText: 'Enter your todo'),
                      onChanged: (text) {},
                    ),
                    actions: [
                      FlatButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Cancel')),
                      FlatButton(
                          onPressed: () {
                            _saveTodo();
                          },
                          child: Text('Save'))
                    ],
                  );
                });
          },
          child: Icon(Icons.add),
          backgroundColor: Colors.black54,
        ),
        body: Column(
          children: [
            Expanded(
                child: ListView.builder(
              itemBuilder: _createItemList,
              itemCount: _todoList.length,
            ))
          ],
        ));
  }
}
