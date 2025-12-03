import 'package:flutter/material.dart';

import '../models/task.dart';

class TaskFormSheet extends StatefulWidget {
  const TaskFormSheet({super.key, this.initialTask});

  final Task? initialTask;

  static Future<TaskFormResult?> show(BuildContext context, {Task? task}) {
    return showModalBottomSheet<TaskFormResult>(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: TaskFormSheet(initialTask: task),
      ),
    );
  }

  @override
  State<TaskFormSheet> createState() => _TaskFormSheetState();
}

class _TaskFormSheetState extends State<TaskFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late TaskCategory _category;
  late TaskPriority _priority;
  DateTime? _dueDate;
  bool _reminder = false;

  @override
  void initState() {
    super.initState();
    final task = widget.initialTask;
    _titleController = TextEditingController(text: task?.title ?? '');
    _descriptionController = TextEditingController(
      text: task?.description ?? '',
    );
    _category = task?.category ?? TaskCategory.personal;
    _priority = task?.priority ?? TaskPriority.medium;
    _dueDate = task?.dueDate;
    _reminder = task?.hasReminder ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.initialTask == null ? 'Add task' : 'Edit task',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Title is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<TaskCategory>(
                        initialValue: _category,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                        ),
                        items: TaskCategory.values
                            .map(
                              (category) => DropdownMenuItem(
                                value: category,
                                child: Text(_categoryLabel(category)),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _category = value);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<TaskPriority>(
                        initialValue: _priority,
                        decoration: const InputDecoration(
                          labelText: 'Priority',
                          border: OutlineInputBorder(),
                        ),
                        items: TaskPriority.values
                            .map(
                              (priority) => DropdownMenuItem(
                                value: priority,
                                child: Text(_priorityLabel(priority)),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _priority = value);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickDueDate,
                        icon: const Icon(Icons.event),
                        label: Text(
                          _dueDate == null
                              ? 'Add due date'
                              : MaterialLocalizations.of(
                                  context,
                                ).formatMediumDate(_dueDate!),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (_dueDate != null)
                      IconButton(
                        tooltip: 'Clear due date',
                        onPressed: () => setState(() {
                          _dueDate = null;
                          _reminder = false;
                        }),
                        icon: const Icon(Icons.close),
                      ),
                  ],
                ),
                SwitchListTile.adaptive(
                  title: const Text('Set reminder'),
                  subtitle: const Text(
                    'Receive a notification at the due time',
                  ),
                  value: _reminder && _dueDate != null,
                  onChanged: _dueDate == null
                      ? null
                      : (value) => setState(() => _reminder = value),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    onPressed: _submit,
                    icon: const Icon(Icons.check),
                    label: const Text('Save'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: DateTime(now.year + 5),
    );
    if (date == null) return;

    final timeOfDay = await showTimePicker(
      context: context,
      initialTime: _dueDate != null
          ? TimeOfDay.fromDateTime(_dueDate!)
          : TimeOfDay.now(),
    );

    if (!mounted) return;

    final time = timeOfDay ?? TimeOfDay.now();
    setState(() {
      _dueDate = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final result = TaskFormResult(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      category: _category,
      priority: _priority,
      dueDate: _dueDate,
      remind: _reminder && _dueDate != null,
    );

    Navigator.of(context).pop(result);
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
}

class TaskFormResult {
  TaskFormResult({
    required this.title,
    this.description,
    required this.category,
    required this.priority,
    this.dueDate,
    this.remind = false,
  });

  final String title;
  final String? description;
  final TaskCategory category;
  final TaskPriority priority;
  final DateTime? dueDate;
  final bool remind;
}
