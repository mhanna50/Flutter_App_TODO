# Pro To-Do

A polished Flutter productivity app for macOS, iOS, Android, Windows, Linux, and web. It showcases clean architecture, Provider-based state management, persistent storage with `shared_preferences`, local notifications, rich task filtering, and a dashboard full of productivity stats.

https://github.com/micha/Flutter_App_TODO

## Table of Contents
- [Highlights](#highlights)
- [App Structure](#app-structure)
- [Features](#features)
- [Getting Started](#getting-started)
- [Running the App](#running-the-app)
- [Testing](#testing)
- [Extending the App](#extending-the-app)

## Overview

Pro To-Do is a multi-platform Flutter app built as a showcase of modern architecture: a Material 3 task manager with persistence, reminders, analytics, and settings.
The repo is structured into lib/models, services, providers, screens, and widgets, keeping business logic separate from UI.

## How It Works

- `main.dart` bootstraps Flutter, loads persisted tasks/settings via `TaskService`/`SettingsService`, initializes `NotificationService`, and wires up `SettingsProvider` + `TaskProvider` using Provider.
- `TaskProvider` holds every task, tracks filters/search/sort, computes stats (completion counts, streak, chart data), persists changes, and schedules notifications. `SettingsProvider` stores theme, default sort, and notification toggle.
- `tasks_screen.dart` is the primary UI: search field, filter chips, segmented sort, and a ListView of `TaskCard`s inside an `AnimatedSwitcher`. Bottom-sheet form (`TaskFormSheet`) lets you add/edit tasks with description, priority, category, due date, and reminder toggle. Swipe actions use `Dismissible` for complete/delete with undo.
- `notification_service.dart` wraps `flutter_local_notifications`, `timezone`, and `flutter_native_timezone` to schedule reminders at due dates, request permissions on iOS/macOS, and cancel/reschedule when tasks change or notifications are disabled.
- `dashboard_screen.dart` listens to `TaskProvider` for totals, completion rate, streak, and renders a 7-day completion bar chart using `fl_chart`.
- `settings_screen.dart` offers theme selection, default sort, notification toggle, and a “clear all tasks” action; it syncs settings back into providers.
- Shared widgets (`task_card.dart`, `task_filter_bar.dart`, `task_form_sheet.dart`, `task_search_field.dart`, `empty_state.dart`) keep the UI consistent and reusable.

## How It Was Built

Started from a simple in-memory todo sample, refactored by:
1. Introducing models (`Task`, `AppSettings`) and enums.
2. Adding persistence layers (`TaskService`, `SettingsService`) backed by `shared_preferences`.
3. Setting up Provider-based state (`TaskProvider` tracks data + stats, `SettingsProvider` for preferences).
4. Rebuilding the tasks screen with Material 3 components, swipe gestures, search/filter/sort, and bottom-sheet forms.
5. Integrating `flutter_local_notifications` plus timezone handling for due-date reminders.
6. Creating additional screens: Dashboard with `fl_chart`, Settings for theme/sort/notifications/clear-all.
7. Adding reusable widgets and styling, ensuring animations and responsive layout.
8. Updating tests to reflect the new flow (`flutter test`), and writing a comprehensive README.

## Highlights
- **Modern Material 3 UI** with cards, chips, and implicit animations.
- **Provider architecture** keeps business logic and UI cleanly separated.
- **Shared Preferences persistence** serializes every task and user setting.
- **Local notifications** remind users about tasks with due dates.
- **Dashboard & Settings** screens demonstrate multi-screen navigation and state synchronization.
- **Cross-platform ready** for macOS, iOS, Android, Windows, Linux, and web.

## App Structure
```
lib/
├── main.dart                   # App bootstrap, providers, theming
├── models/
│   ├── settings.dart           # Theme, sort, notification preferences
│   └── task.dart               # Task entity + enums
├── providers/
│   ├── settings_provider.dart  # ChangeNotifier for settings
│   └── task_provider.dart      # ChangeNotifier for tasks, filters, stats
├── screens/
│   ├── dashboard_screen.dart   # Productivity stats + bar chart
│   ├── settings_screen.dart    # Theme, sort order, notifications, clear all
│   └── tasks_screen.dart       # Main task list UI
├── services/
│   ├── notification_service.dart # flutter_local_notifications wrapper
│   ├── settings_service.dart      # SharedPrefs wrapper for settings
│   └── task_service.dart          # SharedPrefs wrapper for tasks
└── widgets/
    ├── empty_state.dart
    ├── task_card.dart
    ├── task_filter_bar.dart
    ├── task_form_sheet.dart
    └── task_search_field.dart
```

## Features
### Task management
- Create, edit, delete, and toggle tasks from the main list.
- Rich metadata: description, due date/time, priority, and category.
- Swipe gestures: swipe right to complete, left to delete with undo Snackbar.
- Floating action button opens an animated bottom sheet form.
- Search bar, category chips, status filter, and segmented sort control.
- Empty-state messaging and AnimatedSwitcher transitions keep the UI lively.

### Persistence & notifications
- Tasks are encoded as JSON maps and stored via `shared_preferences`.
- Settings (theme, default sort, notifications toggle) persist separately.
- NotificationService wraps `flutter_local_notifications`, `flutter_native_timezone`, and `timezone` to schedule reminders at due dates; toggles cancel/reschedule en masse.

### Dashboard
- `fl_chart` bar chart visualizes completions over the last 7 days.
- KPI tiles summarize totals, today/week completions, completion rate, and streak.

### Settings
- Theme picker (system/light/dark) updates `ThemeMode` instantly.
- Default sort option syncs with TaskProvider ordering.
- Global notification toggle wires back into the provider to cancel/reschedule reminders.
- “Danger zone” clear-all button wipes tasks with confirmation dialogue.

### Testing
- Widget test (`test/widget_test.dart`) pumps the app, creates a task, marks it complete, and verifies state changes using mock SharedPreferences and a fake notification service.

## Getting Started
1. **Install Flutter** 3.10+ and platform toolchains (Xcode for iOS/macOS, Android Studio for Android).
2. Clone the repository:
   ```bash
   git clone https://github.com/micha/Flutter_App_TODO.git
   cd Flutter_App_TODO
   ```
3. Fetch dependencies:
   ```bash
   flutter pub get
   ```

## Running the App
- **macOS desktop:** `flutter run -d macos`
- **iOS Simulator:**
  ```bash
  open -a Simulator
  xcrun simctl boot "iPhone 16"
  flutter run -d "iPhone 16"
  ```
- **Android emulator/device:** `flutter run -d <device_id>` (configure Android Studio + SDK first).
- **Web:** `flutter run -d chrome` (install Chrome or set `CHROME_EXECUTABLE`).
- **Other desktops:** `flutter run -d windows` or `flutter run -d linux` on their respective platforms.

Hot reload works across all targets by pressing `r` in the running terminal session.

## Testing
Run the test suite with:
```bash
flutter test
```

## Extending the App
Ideas for future improvements:
1. Recurring tasks with snooze + rescheduling logic.
2. Dedicated task detail view, checklists, or attachments.
3. Calendar or Kanban layouts alongside the list view.
4. Additional integration tests and golden tests for visual regressions.
5. Localization + accessibility tweaks (voice labels, larger text modes).

Contributions and experiments are welcome—this project is designed to be a portfolio-ready playground for advanced Flutter techniques.
