import 'dart:convert';

enum TaskCategory { work, personal, errands, other }

enum TaskPriority { low, medium, high }

class Task {
  final String id;
  final String title;
  final String? description;
  final bool isCompleted;
  final TaskCategory category;
  final TaskPriority priority;
  final DateTime? dueDate;
  final DateTime createdAt;
  final DateTime? completedAt;
  final bool hasReminder;

  const Task({
    required this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
    this.category = TaskCategory.personal,
    this.priority = TaskPriority.medium,
    this.dueDate,
    required this.createdAt,
    this.completedAt,
    this.hasReminder = false,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    TaskCategory? category,
    TaskPriority? priority,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? completedAt,
    bool? hasReminder,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      hasReminder: hasReminder ?? this.hasReminder,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'category': category.name,
      'priority': priority.name,
      'dueDate': dueDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'hasReminder': hasReminder,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      isCompleted: map['isCompleted'] as bool? ?? false,
      category: TaskCategory.values.firstWhere(
        (c) => c.name == map['category'],
        orElse: () => TaskCategory.personal,
      ),
      priority: TaskPriority.values.firstWhere(
        (p) => p.name == map['priority'],
        orElse: () => TaskPriority.medium,
      ),
      dueDate: map['dueDate'] != null
          ? DateTime.tryParse(map['dueDate'] as String)
          : null,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
      completedAt: map['completedAt'] != null
          ? DateTime.tryParse(map['completedAt'] as String)
          : null,
      hasReminder: map['hasReminder'] as bool? ?? false,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory Task.fromJson(String source) =>
      Task.fromMap(jsonDecode(source) as Map<String, dynamic>);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Task &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.isCompleted == isCompleted &&
        other.category == category &&
        other.priority == priority &&
        other.dueDate == dueDate &&
        other.createdAt == createdAt &&
        other.completedAt == completedAt &&
        other.hasReminder == hasReminder;
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    description,
    isCompleted,
    category,
    priority,
    dueDate,
    createdAt,
    completedAt,
    hasReminder,
  );
}
