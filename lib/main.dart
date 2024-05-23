import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDirectory = await path_provider.getApplicationDocumentsDirectory();
  Hive.init(appDocumentDirectory.path);
  await Hive.openBox<String>('todos');
  runApp(TodoApp());
}

class TodoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo List',
      home: TodoListScreen(),
    );
  }
}

class TodoListScreen extends StatefulWidget {
  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo List'),
      ),
      body: FutureBuilder(
        future: Hive.openBox<String>('todos'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            final box = Hive.box<String>('todos');
            return ListView.builder(
              itemCount: box.length,
              itemBuilder: (context, index) {
                final todo = box.getAt(index);
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: ListTile(
                    title: Text('$todo'),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _removeTodoItem(index),
                    ),
                  ),
                );
              },
            );
          } else {
            return CircularProgressIndicator();
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newTask = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTodoScreen()),
          );
          if (newTask != null) {
            _addTodoItem(newTask);
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _addTodoItem(String task) async {
    if (task.isNotEmpty) {
      final box = await Hive.openBox<String>('todos');
      box.add(task);
      setState(() {});
    }
  }

  void _removeTodoItem(int index) async {
    final box = await Hive.openBox<String>('todos');
    box.deleteAt(index);
    setState(() {});
  }
}

class AddTodoScreen extends StatelessWidget {
  final TextEditingController _textFieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Todo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: _textFieldController,
          decoration: InputDecoration(hintText: 'Enter your task'),
          onSubmitted: (value) {
            Navigator.pop(context, value);
          },
        ),
      ),
    );
  }
}
