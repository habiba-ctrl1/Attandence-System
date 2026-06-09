// lib/core/constants.dart
import 'package:flutter/material.dart';

class AppConstants {
  static const String adminEmail = 'admin@school.com';
  static const String adminPassword = 'admin123';
  static const String studentEmail = 'student@school.com';
  static const String studentPassword = 'student123';
  static const String studentsKey = 'students_data_v2';
  static const String leavesKey = 'leaves_data_v2';
  static const String savedDatesKey = 'saved_dates_v2';
  static const String settingsKey = 'app_settings_v2';
  static const double lowAttendanceThreshold = 75.0;

  static const Color primaryColor = Color(0xffad1457);
  static const Color primaryLight = Color(0xfff06292);
  static const Color bgPink = Color(0xfffce4ec);

  static const List<String> leaveTypes = [
    'Sick Leave',
    'Family Event',
    'Emergency',
    'Medical Appointment',
    'Other',
  ];
}
