import 'package:flutter/material.dart';

import '../models/settings.dart';
import '../services/settings_service.dart';

class SettingsProvider extends ChangeNotifier {
  SettingsProvider({
    required this.settingsService,
    required AppSettings initialSettings,
  }) : _settings = initialSettings;

  final SettingsService settingsService;
  AppSettings _settings;

  ThemeMode get themeMode => _settings.themeMode;
  TaskSortOption get defaultSortOption => _settings.defaultSortOption;
  bool get notificationsEnabled => _settings.notificationsEnabled;

  Future<void> updateThemeMode(ThemeMode mode) async {
    _settings = _settings.copyWith(themeMode: mode);
    await settingsService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> updateDefaultSortOption(TaskSortOption option) async {
    _settings = _settings.copyWith(defaultSortOption: option);
    await settingsService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> toggleNotifications(bool enabled) async {
    _settings = _settings.copyWith(notificationsEnabled: enabled);
    await settingsService.saveSettings(_settings);
    notifyListeners();
  }
}
