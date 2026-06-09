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

  // Professional Deep Blue palette
  static const Color primaryColor = Color(0xff1565C0);   // Blue 800
  static const Color primaryLight = Color(0xff1E88E5);   // Blue 600
  static const Color primaryDark  = Color(0xff0D47A1);   // Blue 900
  static const Color bgPink       = Color(0xffE3F2FD);   // Blue 50 (light bg)

  static const List<String> leaveTypes = [
    'Sick Leave',
    'Family Event',
    'Emergency',
    'Medical Appointment',
    'Other',
  ];
}
