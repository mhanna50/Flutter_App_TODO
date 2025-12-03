import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/task.dart';

class TaskService {
  static const _storageKey = 'tasks';

  Future<List<Task>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_storageKey);
    if (stored == null) {
      return [];
    }

    return stored
        .map((raw) => Task.fromMap(jsonDecode(raw) as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = tasks.map((task) => jsonEncode(task.toMap())).toList();
    await prefs.setStringList(_storageKey, encoded);
  }

  Future<void> clearTasks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}
