import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';

import '../models/settings.dart';
import '../models/task.dart';
import '../services/notification_service.dart';
import '../services/task_service.dart';

enum TaskFilterStatus { all, active, completed }

class TaskProvider extends ChangeNotifier {
  TaskProvider({
    required this.taskService,
    required this.notificationService,
    required List<Task> initialTasks,
    required TaskSortOption defaultSortOption,
    bool notificationsEnabled = true,
  }) : _tasks = List<Task>.from(initialTasks),
       _sortOption = defaultSortOption,
       _notificationsEnabled = notificationsEnabled {
    _applyFilters();
    if (_notificationsEnabled) {
      _schedulePendingReminders();
    }
  }

  final TaskService taskService;
  final NotificationService notificationService;

  final List<Task> _tasks;
  List<Task> _visibleTasks = const [];

  String _searchQuery = '';
  TaskCategory? _categoryFilter;
  TaskFilterStatus _statusFilter = TaskFilterStatus.all;
  TaskSortOption _sortOption;
  bool _notificationsEnabled;

  List<Task> get tasks => List.unmodifiable(_visibleTasks);
  List<Task> get allTasks => List.unmodifiable(_tasks);
  String get searchQuery => _searchQuery;
  TaskCategory? get categoryFilter => _categoryFilter;
  TaskFilterStatus get statusFilter => _statusFilter;
  TaskSortOption get sortOption => _sortOption;

  int get totalTasks => _tasks.length;
  int get completedTasks => _tasks.where((task) => task.isCompleted).length;
  int get completedToday => _tasks
      .where(
        (task) =>
            task.isCompleted &&
            task.completedAt != null &&
            _isSameDay(task.completedAt!, DateTime.now()),
      )
      .length;
  int get completedThisWeek => _tasks
      .where(
        (task) =>
            task.isCompleted &&
            task.completedAt != null &&
            task.completedAt!.isAfter(
              DateTime.now().subtract(const Duration(days: 7)),
            ),
      )
      .length;
  double get completionRate =>
      totalTasks == 0 ? 0 : completedTasks / totalTasks;

  int get streak => _calculateStreak();

  Map<DateTime, int> completionsByDay(int days) {
    final now = DateTime.now();
    final today = _normalizeDate(now);
    final Map<DateTime, int> counts = {};

    for (int i = days - 1; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      counts[date] = 0;
    }

    for (final task in _tasks) {
      if (!task.isCompleted || task.completedAt == null) continue;
      final completedDate = _normalizeDate(task.completedAt!);
      if (counts.containsKey(completedDate)) {
        counts[completedDate] = counts[completedDate]! + 1;
      }
    }

    final ordered = counts.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return LinkedHashMap.fromEntries(ordered);
  }

  Future<void> createTask({
    required String title,
    String? description,
    TaskCategory category = TaskCategory.personal,
    TaskPriority priority = TaskPriority.medium,
    DateTime? dueDate,
    bool remind = false,
  }) async {
    final task = Task(
      id: _generateId(),
      title: title,
      description: description,
      category: category,
      priority: priority,
      dueDate: dueDate,
      createdAt: DateTime.now(),
      hasReminder: remind,
    );

    _tasks.insert(0, task);
    await _persist();
    _applyFilters();

    if (remind && _notificationsEnabled) {
      await notificationService.scheduleTaskReminder(task);
    }
  }

  Future<void> updateTask(
    String id, {
    required String title,
    String? description,
    TaskCategory? category,
    TaskPriority? priority,
    DateTime? dueDate,
    bool remind = false,
  }) async {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index == -1) return;

    final existing = _tasks[index];
    final updated = existing.copyWith(
      title: title,
      description: description,
      category: category ?? existing.category,
      priority: priority ?? existing.priority,
      dueDate: dueDate,
      hasReminder: remind,
    );

    _tasks[index] = updated;
    await _persist();
    _applyFilters();

    if (remind && _notificationsEnabled) {
      await notificationService.scheduleTaskReminder(updated);
    } else {
      await notificationService.cancelTaskReminder(updated.id);
    }
  }

  Future<void> toggleCompletion(String id) async {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index == -1) return;

    final task = _tasks[index];
    final completed = !task.isCompleted;
    final updated = task.copyWith(
      isCompleted: completed,
      completedAt: completed ? DateTime.now() : null,
    );

    _tasks[index] = updated;
    await _persist();
    _applyFilters();

    if (completed) {
      await notificationService.cancelTaskReminder(task.id);
    } else if (updated.hasReminder &&
        updated.dueDate != null &&
        _notificationsEnabled) {
      await notificationService.scheduleTaskReminder(updated);
    }
  }

  Future<Task?> deleteTask(String id) async {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index == -1) return null;

    final removed = _tasks.removeAt(index);
    await _persist();
    _applyFilters();
    await notificationService.cancelTaskReminder(removed.id);
    return removed;
  }

  Future<void> restoreTask(Task task) async {
    _tasks.insert(0, task);
    await _persist();
    _applyFilters();
    if (task.hasReminder && task.dueDate != null && _notificationsEnabled) {
      await notificationService.scheduleTaskReminder(task);
    }
  }

  Future<void> clearAllTasks() async {
    _tasks.clear();
    await taskService.clearTasks();
    await notificationService.cancelAll();
    _applyFilters();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void setCategoryFilter(TaskCategory? category) {
    _categoryFilter = category;
    _applyFilters();
  }

  void setStatusFilter(TaskFilterStatus status) {
    _statusFilter = status;
    _applyFilters();
  }

  void updateSortOption(TaskSortOption option) {
    if (_sortOption == option) return;
    _sortOption = option;
    _applyFilters();
  }

  void applyDefaultSort(TaskSortOption option) {
    _sortOption = option;
    _applyFilters();
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    if (_notificationsEnabled == enabled) return;
    _notificationsEnabled = enabled;
    if (!enabled) {
      await notificationService.cancelAll();
    } else {
      await _schedulePendingReminders();
    }
  }

  void _applyFilters() {
    Iterable<Task> result = List<Task>.from(_tasks);

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result.where(
        (task) =>
            task.title.toLowerCase().contains(query) ||
            (task.description?.toLowerCase().contains(query) ?? false),
      );
    }

    if (_categoryFilter != null) {
      result = result.where((task) => task.category == _categoryFilter);
    }

    if (_statusFilter == TaskFilterStatus.active) {
      result = result.where((task) => !task.isCompleted);
    } else if (_statusFilter == TaskFilterStatus.completed) {
      result = result.where((task) => task.isCompleted);
    }

    result = result.toList()..sort((a, b) => _compareTasks(a, b, _sortOption));

    _visibleTasks = result.toList();
    notifyListeners();
  }

  int _compareTasks(Task a, Task b, TaskSortOption option) {
    switch (option) {
      case TaskSortOption.dueDate:
        final aDue = a.dueDate ?? DateTime(2100);
        final bDue = b.dueDate ?? DateTime(2100);
        return aDue.compareTo(bDue);
      case TaskSortOption.createdAt:
        return b.createdAt.compareTo(a.createdAt);
      case TaskSortOption.priority:
        return _priorityScore(b.priority).compareTo(_priorityScore(a.priority));
    }
  }

  int _priorityScore(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return 3;
      case TaskPriority.medium:
        return 2;
      case TaskPriority.low:
        return 1;
    }
  }

  Future<void> _schedulePendingReminders() async {
    for (final task in _tasks) {
      if (task.isCompleted || !task.hasReminder || task.dueDate == null) {
        continue;
      }
      if (task.dueDate!.isAfter(DateTime.now())) {
        await notificationService.scheduleTaskReminder(task);
      }
    }
  }

  Future<void> _persist() => taskService.saveTasks(_tasks);

  bool _isSameDay(DateTime a, DateTime b) {
    return _normalizeDate(a) == _normalizeDate(b);
  }

  int _calculateStreak() {
    int streak = 0;
    final dates = _tasks
        .where((task) => task.isCompleted && task.completedAt != null)
        .map((task) => _normalizeDate(task.completedAt!))
        .toSet();

    var cursor = _normalizeDate(DateTime.now());

    while (dates.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    return streak;
  }

  DateTime _normalizeDate(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  String _generateId() {
    final random = Random().nextInt(999999);
    return '${DateTime.now().microsecondsSinceEpoch}-$random';
  }
}
