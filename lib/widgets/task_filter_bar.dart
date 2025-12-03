import 'package:flutter/material.dart';

import '../models/settings.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';

class TaskFilterBar extends StatelessWidget {
  const TaskFilterBar({
    super.key,
    required this.selectedCategory,
    required this.status,
    required this.sortOption,
    required this.onCategoryChanged,
    required this.onStatusChanged,
    required this.onSortChanged,
  });

  final TaskCategory? selectedCategory;
  final TaskFilterStatus status;
  final TaskSortOption sortOption;
  final ValueChanged<TaskCategory?> onCategoryChanged;
  final ValueChanged<TaskFilterStatus> onStatusChanged;
  final ValueChanged<TaskSortOption> onSortChanged;

  @override
  Widget build(BuildContext context) {
    final categories = TaskCategory.values;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: TaskFilterStatus.values.map((filter) {
            final active = filter == status;
            return FilterChip(
              label: Text(_statusLabel(filter)),
              selected: active,
              onSelected: (_) => onStatusChanged(filter),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: const Text('All categories'),
              selected: selectedCategory == null,
              onSelected: (_) => onCategoryChanged(null),
            ),
            ...categories.map(
              (category) => ChoiceChip(
                label: Text(_categoryLabel(category)),
                selected: selectedCategory == category,
                onSelected: (_) => onCategoryChanged(category),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Text('Sort by:'),
            SegmentedButton<TaskSortOption>(
              segments: TaskSortOption.values
                  .map(
                    (option) => ButtonSegment(
                      value: option,
                      label: Text(_sortLabel(option)),
                    ),
                  )
                  .toList(),
              selected: <TaskSortOption>{sortOption},
              onSelectionChanged: (selection) => onSortChanged(selection.first),
            ),
          ],
        ),
      ],
    );
  }

  String _statusLabel(TaskFilterStatus status) {
    switch (status) {
      case TaskFilterStatus.all:
        return 'All';
      case TaskFilterStatus.active:
        return 'Active';
      case TaskFilterStatus.completed:
        return 'Completed';
    }
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

  String _sortLabel(TaskSortOption option) {
    switch (option) {
      case TaskSortOption.dueDate:
        return 'Due date';
      case TaskSortOption.createdAt:
        return 'Created';
      case TaskSortOption.priority:
        return 'Priority';
    }
  }
}
