import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/settings.dart';
import '../providers/settings_provider.dart';
import '../providers/task_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const routeName = '/settings';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Consumer2<SettingsProvider, TaskProvider>(
        builder: (context, settings, tasks, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Appearance',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: DropdownMenu<ThemeMode>(
                  initialSelection: settings.themeMode,
                  label: const Text('Theme'),
                  dropdownMenuEntries: ThemeMode.values
                      .map(
                        (mode) => DropdownMenuEntry(
                          value: mode,
                          label: _themeLabel(mode),
                        ),
                      )
                      .toList(),
                  onSelected: (mode) async {
                    if (mode != null) {
                      await settings.updateThemeMode(mode);
                    }
                  },
                ),
              ),
              const SizedBox(height: 24),
              Text('Tasks', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: DropdownMenu<TaskSortOption>(
                  initialSelection: settings.defaultSortOption,
                  label: const Text('Default sort order'),
                  dropdownMenuEntries: TaskSortOption.values
                      .map(
                        (option) => DropdownMenuEntry(
                          value: option,
                          label: _sortLabel(option),
                        ),
                      )
                      .toList(),
                  onSelected: (option) async {
                    if (option != null) {
                      await settings.updateDefaultSortOption(option);
                      tasks.applyDefaultSort(option);
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile.adaptive(
                title: const Text('Enable notifications'),
                subtitle: const Text('Allow reminders for due tasks'),
                value: settings.notificationsEnabled,
                onChanged: (value) async {
                  await settings.toggleNotifications(value);
                  await tasks.setNotificationsEnabled(value);
                },
              ),
              const SizedBox(height: 24),
              Text(
                'Danger zone',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              FilledButton.tonalIcon(
                icon: const Icon(Icons.delete_sweep_outlined),
                label: const Text('Clear all tasks'),
                style: FilledButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Clear all tasks?'),
                      content: const Text(
                        'This will remove every task permanently. This action cannot be undone.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Clear'),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    await tasks.clearAllTasks();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('All tasks cleared')),
                      );
                    }
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }

  String _themeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System default';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }

  String _sortLabel(TaskSortOption option) {
    switch (option) {
      case TaskSortOption.dueDate:
        return 'Due date';
      case TaskSortOption.createdAt:
        return 'Created date';
      case TaskSortOption.priority:
        return 'Priority';
    }
  }
}
