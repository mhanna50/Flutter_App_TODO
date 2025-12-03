import 'package:flutter/material.dart';

enum TaskSortOption { dueDate, createdAt, priority }

class AppSettings {
  final ThemeMode themeMode;
  final TaskSortOption defaultSortOption;
  final bool notificationsEnabled;

  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.defaultSortOption = TaskSortOption.dueDate,
    this.notificationsEnabled = true,
  });

  AppSettings copyWith({
    ThemeMode? themeMode,
    TaskSortOption? defaultSortOption,
    bool? notificationsEnabled,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      defaultSortOption: defaultSortOption ?? this.defaultSortOption,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'themeMode': themeMode.name,
      'defaultSortOption': defaultSortOption.name,
      'notificationsEnabled': notificationsEnabled,
    };
  }

  factory AppSettings.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return const AppSettings();
    }

    ThemeMode themeMode = ThemeMode.system;
    final themeValue = map['themeMode'] as String?;
    if (themeValue != null) {
      themeMode = ThemeMode.values.firstWhere(
        (mode) => mode.name == themeValue,
        orElse: () => ThemeMode.system,
      );
    }

    TaskSortOption sortOption = TaskSortOption.dueDate;
    final sortValue = map['defaultSortOption'] as String?;
    if (sortValue != null) {
      sortOption = TaskSortOption.values.firstWhere(
        (option) => option.name == sortValue,
        orElse: () => TaskSortOption.dueDate,
      );
    }

    return AppSettings(
      themeMode: themeMode,
      defaultSortOption: sortOption,
      notificationsEnabled: map['notificationsEnabled'] as bool? ?? true,
    );
  }
}
