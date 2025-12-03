import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/settings.dart';

class SettingsService {
  static const _storageKey = 'app_settings';

  Future<AppSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null) {
      return const AppSettings();
    }

    return AppSettings.fromMap(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveSettings(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(settings.toMap()));
  }
}
