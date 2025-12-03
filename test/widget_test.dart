import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_app_todo/models/settings.dart';
import 'package:flutter_app_todo/models/task.dart';
import 'package:flutter_app_todo/providers/task_provider.dart';
import 'package:flutter_app_todo/screens/tasks_screen.dart';
import 'package:flutter_app_todo/services/notification_service.dart';
import 'package:flutter_app_todo/services/task_service.dart';

class _FakeNotificationService implements NotificationService {
  @override
  Future<void> cancelAll() async {}

  @override
  Future<void> cancelTaskReminder(String taskId) async {}

  @override
  Future<void> init() async {}

  @override
  Future<void> scheduleTaskReminder(Task task) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('user can add and complete a task', (WidgetTester tester) async {
    final taskService = TaskService();
    final notificationService = _FakeNotificationService();

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider(
          create: (_) => TaskProvider(
            taskService: taskService,
            notificationService: notificationService,
            initialTasks: const [],
            defaultSortOption: TaskSortOption.dueDate,
          ),
          child: const TasksScreen(),
        ),
      ),
    );

    await tester.pump();

    expect(
      find.text('No tasks yet. Tap the + button to create one.'),
      findsOneWidget,
    );

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'Buy groceries');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Buy groceries'), findsOneWidget);

    await tester.tap(find.byType(Checkbox).first);
    await tester.pumpAndSettle();

    final checkbox = tester.widget<Checkbox>(find.byType(Checkbox).first);
    expect(checkbox.value, isTrue);
  });
}
