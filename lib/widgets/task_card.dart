import 'package:flutter/material.dart';

import '../models/task.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.onToggleCompletion,
    required this.onEdit,
  });

  final Task task;
  final ValueChanged<bool?> onToggleCompletion;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dueDateText = task.dueDate != null
        ? 'Due ${MaterialLocalizations.of(context).formatMediumDate(task.dueDate!)}'
        : null;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: task.isCompleted ? 0.6 : 1,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          leading: Checkbox(
            value: task.isCompleted,
            onChanged: onToggleCompletion,
            shape: const CircleBorder(),
          ),
          title: Text(
            task.title,
            style: theme.textTheme.titleMedium?.copyWith(
              decoration: task.isCompleted
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (task.description != null && task.description!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    task.description!,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    _Chip(
                      label: _categoryLabel(task.category),
                      color: _categoryColor(task.category, theme),
                    ),
                    _Chip(
                      label: _priorityLabel(task.priority),
                      color: _priorityColor(task.priority, theme),
                    ),
                    if (dueDateText != null)
                      _Chip(
                        label: dueDateText,
                        color: theme.colorScheme.surfaceContainerHighest,
                      ),
                  ],
                ),
              ),
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit task',
            onPressed: onEdit,
          ),
        ),
      ),
    );
  }

  String _categoryLabel(TaskCategory category) {
    switch (category) {
      case TaskCategory.work:
        return 'Work';
      case TaskCategory.personal:
        return 'Personal';
      case TaskCategory.errands:
        return 'Errands';
      case TaskCategory.other:
        return 'Other';
    }
  }

  String _priorityLabel(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return 'High';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.low:
        return 'Low';
    }
  }

  Color _categoryColor(TaskCategory category, ThemeData theme) {
    switch (category) {
      case TaskCategory.work:
        return theme.colorScheme.primaryContainer;
      case TaskCategory.personal:
        return theme.colorScheme.secondaryContainer;
      case TaskCategory.errands:
        return theme.colorScheme.tertiaryContainer;
      case TaskCategory.other:
        return theme.colorScheme.surfaceContainerHighest;
    }
  }

  Color _priorityColor(TaskPriority priority, ThemeData theme) {
    switch (priority) {
      case TaskPriority.high:
        return theme.colorScheme.errorContainer;
      case TaskPriority.medium:
        return theme.colorScheme.surfaceContainerHighest;
      case TaskPriority.low:
        return theme.colorScheme.inversePrimary;
    }
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final onColor =
        ThemeData.estimateBrightnessForColor(color) == Brightness.dark
        ? Colors.white
        : Colors.black87;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: TextStyle(fontSize: 12, color: onColor)),
    );
  }
}
