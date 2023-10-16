import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() => runApp(const TodoNotesApp());

class TodoNotesApp extends StatelessWidget {
  const TodoNotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'To-do Notes',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const TodoListPage(),
    );
  }
}

class Todo {
  String title;
  bool isDone;

  Todo({required this.title, required this.isDone});

  // JSON serialization
  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      title: json['title'],
      isDone: json['isDone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'isDone': isDone,
    };
  }
}

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  TodoListPageState createState() => TodoListPageState();
}

class TodoListPageState extends State<TodoListPage> {
  List<Todo> _todos = [];
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To-do Notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveTodos,
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: _todos.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_todos[index].title),
                  trailing: Checkbox(
                    value: _todos[index].isDone,
                    onChanged: (bool? value) {
                      setState(() {
                        _todos[index].isDone = value!;
                      });
                    },
                  ),
                  onTap: () => _editTodo(index),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _textController,
              onSubmitted: _addTodo,
              decoration: InputDecoration(
                hintText: 'Enter a to-do item...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    _addTodo(_textController.text);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addTodo(String title) {
    if (title.isNotEmpty) {
      setState(() {
        _todos.add(Todo(title: title, isDone: false));
        _textController.clear();
      });
    }
  }

  void _editTodo(int index) async {
    String? newTitle = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Todo'),
        content: TextField(
          controller: TextEditingController(text: _todos[index].title),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('Save'),
            onPressed: () => Navigator.pop(context, _textController.text),
          ),
        ],
      ),
    );

    if (newTitle != null && newTitle.isNotEmpty) {
      setState(() {
        _todos[index].title = newTitle;
      });
    }
  }

  _saveTodos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> stringTodos =
        _todos.map((todo) => json.encode(todo.toJson())).toList();
    prefs.setStringList('todos', stringTodos);
  }

  _loadTodos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? stringTodos = prefs.getStringList('todos');

    if (stringTodos != null) {
      setState(() {
        _todos = stringTodos
            .map((todo) => Todo.fromJson(json.decode(todo)))
            .toList();
      });
    }
  }
}
