import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple To-Do',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      home: const TodoPage(),
    );
  }
}

class TodoItem {
  String title;
  bool isDone;

  TodoItem({required this.title, this.isDone = false});

  Map<String, dynamic> toJson() => {'title': title, 'isDone': isDone};

  factory TodoItem.fromJson(Map<String, dynamic> json) {
    return TodoItem(
      title: json['title'] as String,
      isDone: json['isDone'] as bool? ?? false,
    );
  }
}

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final List<TodoItem> _todos = [];
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = true;

  static const String _storageKey = 'todos';

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_storageKey);

    if (stored != null) {
      _todos.clear();
      for (final item in stored) {
        final decoded = jsonDecode(item) as Map<String, dynamic>;
        _todos.add(TodoItem.fromJson(decoded));
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = _todos.map((t) => jsonEncode(t.toJson())).toList();
    await prefs.setStringList(_storageKey, encoded);
  }

  Future<void> _addTodo() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _todos.insert(0, TodoItem(title: text));
      _controller.clear();
    });

    await _saveTodos();
  }

  Future<void> _toggleTodo(int index, bool? value) async {
    setState(() {
      _todos[index].isDone = value ?? false;
    });
    await _saveTodos();
  }

  Future<void> _deleteTodo(int index) async {
    setState(() {
      _todos.removeAt(index);
    });
    await _saveTodos();
  }

  Future<void> _clearCompleted() async {
    setState(() {
      _todos.removeWhere((t) => t.isDone);
    });
    await _saveTodos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple To-Do'),
        actions: [
          IconButton(
            tooltip: 'Clear completed',
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: _todos.any((t) => t.isDone) ? _clearCompleted : null,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          onSubmitted: (_) => _addTodo(),
                          decoration: const InputDecoration(
                            hintText: 'Add a new task...',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton.icon(
                        onPressed: _addTodo,
                        icon: const Icon(Icons.add),
                        label: const Text('Add'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _todos.isEmpty
                      ? const Center(
                          child: Text(
                            'No tasks yet.\nAdd something to do!',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _todos.length,
                          itemBuilder: (context, index) {
                            final todo = _todos[index];
                            return Dismissible(
                              key: ValueKey(todo.title + index.toString()),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                              ),
                              onDismissed: (_) => _deleteTodo(index),
                              child: CheckboxListTile(
                                title: Text(
                                  todo.title,
                                  style: TextStyle(
                                    decoration: todo.isDone
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                    color: todo.isDone
                                        ? Colors.grey
                                        : Colors.black,
                                  ),
                                ),
                                value: todo.isDone,
                                onChanged: (value) => _toggleTodo(index, value),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
