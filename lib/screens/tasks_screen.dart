import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../providers/task_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/task_card.dart';
import '../widgets/task_filter_bar.dart';
import '../widgets/task_form_sheet.dart';
import '../widgets/task_search_field.dart';
import 'dashboard_screen.dart';
import 'settings_screen.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pro To-Do'),
        actions: [
          IconButton(
            tooltip: 'Dashboard',
            icon: const Icon(Icons.bar_chart_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DashboardScreen()),
              );
            },
          ),
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openTaskForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Task'),
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, _) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TaskSearchField(
                  controller: _searchController,
                  onChanged: taskProvider.setSearchQuery,
                ),
                const SizedBox(height: 16),
                TaskFilterBar(
                  selectedCategory: taskProvider.categoryFilter,
                  status: taskProvider.statusFilter,
                  sortOption: taskProvider.sortOption,
                  onCategoryChanged: taskProvider.setCategoryFilter,
                  onStatusChanged: taskProvider.setStatusFilter,
                  onSortChanged: (option) {
                    taskProvider.updateSortOption(option);
                  },
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: taskProvider.tasks.isEmpty
                        ? const EmptyState(
                            message:
                                'No tasks yet. Tap the + button to create one.',
                          )
                        : ListView.separated(
                            itemCount: taskProvider.tasks.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final task = taskProvider.tasks[index];
                              return _buildDismissible(
                                context,
                                taskProvider,
                                task,
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDismissible(
    BuildContext context,
    TaskProvider provider,
    Task task,
  ) {
    return Dismissible(
      key: ValueKey(task.id),
      background: _SwipeBackground(
        alignment: Alignment.centerLeft,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        icon: Icons.check_circle,
        text: task.isCompleted ? 'Mark active' : 'Complete',
      ),
      secondaryBackground: _SwipeBackground(
        alignment: Alignment.centerRight,
        color: Theme.of(context).colorScheme.errorContainer,
        icon: Icons.delete_outline,
        text: 'Delete',
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          await provider.toggleCompletion(task.id);
          return false;
        }

        final removed = await provider.deleteTask(task.id);
        if (!context.mounted || removed == null) {
          return false;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Task deleted'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                provider.restoreTask(removed);
              },
            ),
          ),
        );
        return true;
      },
      child: TaskCard(
        task: task,
        onToggleCompletion: (_) => provider.toggleCompletion(task.id),
        onEdit: () => _openTaskForm(context, task: task),
      ),
    );
  }

  Future<void> _openTaskForm(BuildContext context, {Task? task}) async {
    final result = await TaskFormSheet.show(context, task: task);
    if (!context.mounted || result == null) return;

    final provider = context.read<TaskProvider>();
    if (task == null) {
      await provider.createTask(
        title: result.title,
        description: result.description,
        category: result.category,
        priority: result.priority,
        dueDate: result.dueDate,
        remind: result.remind,
      );
    } else {
      await provider.updateTask(
        task.id,
        title: result.title,
        description: result.description,
        category: result.category,
        priority: result.priority,
        dueDate: result.dueDate,
        remind: result.remind,
      );
    }
  }
}

class _SwipeBackground extends StatelessWidget {
  const _SwipeBackground({
    required this.alignment,
    required this.color,
    required this.icon,
    required this.text,
  });

  final Alignment alignment;
  final Color color;
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      color: color,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon), const SizedBox(width: 8), Text(text)],
      ),
    );
  }
}
