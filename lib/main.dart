import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/settings.dart';
import 'models/task.dart';
import 'providers/settings_provider.dart';
import 'providers/task_provider.dart';
import 'screens/tasks_screen.dart';
import 'services/notification_service.dart';
import 'services/settings_service.dart';
import 'services/task_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final taskService = TaskService();
  final settingsService = SettingsService();
  final notificationService = NotificationService();

  final initialSettings = await settingsService.loadSettings();
  final initialTasks = await taskService.loadTasks();
  await notificationService.init();

  runApp(
    ProTodoApp(
      taskService: taskService,
      settingsService: settingsService,
      notificationService: notificationService,
      initialSettings: initialSettings,
      initialTasks: initialTasks,
    ),
  );
}

class ProTodoApp extends StatelessWidget {
  const ProTodoApp({
    super.key,
    required this.taskService,
    required this.settingsService,
    required this.notificationService,
    required this.initialSettings,
    required this.initialTasks,
  });

  final TaskService taskService;
  final SettingsService settingsService;
  final NotificationService notificationService;
  final AppSettings initialSettings;
  final List<Task> initialTasks;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(
            settingsService: settingsService,
            initialSettings: initialSettings,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => TaskProvider(
            taskService: taskService,
            notificationService: notificationService,
            initialTasks: initialTasks,
            defaultSortOption: initialSettings.defaultSortOption,
            notificationsEnabled: initialSettings.notificationsEnabled,
          ),
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'Pro To-Do',
            debugShowCheckedModeBanner: false,
            themeMode: settings.themeMode,
            theme: ThemeData(
              colorSchemeSeed: Colors.indigo,
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              colorSchemeSeed: Colors.indigo,
              brightness: Brightness.dark,
              useMaterial3: true,
            ),
            home: const TasksScreen(),
          );
        },
      ),
    );
  }
}
