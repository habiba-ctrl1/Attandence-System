// lib/providers/theme_provider.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_settings.dart';
import '../core/constants.dart';

class ThemeProvider extends ChangeNotifier {
  AppSettings _settings = const AppSettings();

  AppSettings get settings => _settings;
  ThemeMode get themeMode =>
      _settings.isDarkMode ? ThemeMode.dark : ThemeMode.light;
  double get fontSize => _settings.fontSize;
  String get schoolName => _settings.schoolName;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(AppConstants.settingsKey);
    if (raw != null) {
      _settings =
          AppSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      notifyListeners();
    }
  }

  Future<void> save(AppSettings s) async {
    _settings = s;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.settingsKey, jsonEncode(s.toJson()));
    notifyListeners();
  }

  void toggleDark() => save(_settings.copyWith(isDarkMode: !_settings.isDarkMode));
  void setFontSize(double v) => save(_settings.copyWith(fontSize: v));
  void setSchoolName(String v) => save(_settings.copyWith(schoolName: v));
}
