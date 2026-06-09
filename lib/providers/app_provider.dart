// lib/providers/app_provider.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/student.dart';
import '../models/leave_request.dart';
import '../core/constants.dart';

class AppProvider extends ChangeNotifier {
  List<Student> _students = [];
  List<LeaveRequest> _leaves = [];
  bool _isLoading = false;
  String? _loggedInStudentId;

  // Undo support
  Student? _lastDeleted;
  int? _lastDeletedIndex;

  // Dates where attendance has been saved/locked
  final Set<String> _savedDates = {};

  // Getters
  List<Student> get students => _students.where((s) => !s.isDeleted).toList();
  List<LeaveRequest> get leaves => _leaves;
  bool get isLoading => _isLoading;
  String? get loggedInStudentId => _loggedInStudentId;
  bool get canUndo => _lastDeleted != null;

  int get pendingLeavesCount =>
      _leaves.where((l) => l.status == 'Pending').length;

  int get presentTodayCount {
    final today = _dateKey(DateTime.now());
    return students.where((s) => s.statusForDate(today) == 'P').length;
  }

  int get absentTodayCount {
    final today = _dateKey(DateTime.now());
    return students.where((s) => s.statusForDate(today) == 'A').length;
  }

  bool isDateSaved(String date) => _savedDates.contains(date);

  String _dateKey(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  Student? get loggedInStudent {
    if (_loggedInStudentId == null) return null;
    try {
      return _students.firstWhere((s) => s.id == _loggedInStudentId);
    } catch (_) {
      return null;
    }
  }

  void setLoggedInStudent(String? id) {
    _loggedInStudentId = id;
    notifyListeners();
  }

  // ── Persistence ─────────────────────────────────────────────────────────────

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();

    final studentsJson = prefs.getString(AppConstants.studentsKey);
    if (studentsJson != null) {
      final list = jsonDecode(studentsJson) as List<dynamic>;
      _students = list.map((e) => Student.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      _students = _defaultStudents();
      await _persistStudents(prefs);
    }

    final leavesJson = prefs.getString(AppConstants.leavesKey);
    if (leavesJson != null) {
      final list = jsonDecode(leavesJson) as List<dynamic>;
      _leaves = list.map((e) => LeaveRequest.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      _leaves = _defaultLeaves();
      await _persistLeaves(prefs);
    }

    final saved = prefs.getStringList(AppConstants.savedDatesKey) ?? [];
    _savedDates
      ..clear()
      ..addAll(saved);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _persistStudents([SharedPreferences? p]) async {
    final prefs = p ?? await SharedPreferences.getInstance();
    await prefs.setString(
      AppConstants.studentsKey,
      jsonEncode(_students.map((s) => s.toJson()).toList()),
    );
  }

  Future<void> _persistLeaves([SharedPreferences? p]) async {
    final prefs = p ?? await SharedPreferences.getInstance();
    await prefs.setString(
      AppConstants.leavesKey,
      jsonEncode(_leaves.map((l) => l.toJson()).toList()),
    );
  }

  // ── Students ─────────────────────────────────────────────────────────────────

  Future<void> addStudent(Student s) async {
    _students.add(s);
    notifyListeners();
    await _persistStudents();
  }

  Future<void> updateStudent(Student updated) async {
    final i = _students.indexWhere((s) => s.id == updated.id);
    if (i != -1) {
      _students[i] = updated;
      notifyListeners();
      await _persistStudents();
    }
  }

  Future<void> softDeleteStudent(String id) async {
    final i = _students.indexWhere((s) => s.id == id);
    if (i != -1) {
      _lastDeleted = _students[i];
      _lastDeletedIndex = i;
      _students[i] = _students[i].copyWith(isDeleted: true);
      notifyListeners();
      await _persistStudents();
    }
  }

  Future<void> undoDelete() async {
    if (_lastDeleted == null) return;
    final idx = _lastDeletedIndex!;
    final restored = _lastDeleted!.copyWith(isDeleted: false);
    if (idx <= _students.length) {
      _students.insert(idx, restored);
    } else {
      _students.add(restored);
    }
    _lastDeleted = null;
    _lastDeletedIndex = null;
    notifyListeners();
    await _persistStudents();
  }

  // ── Attendance ───────────────────────────────────────────────────────────────

  Future<void> markAttendance(String studentId, String date, String status) async {
    final i = _students.indexWhere((s) => s.id == studentId);
    if (i != -1) {
      final map = Map<String, String>.from(_students[i].dateWiseRecord);
      map[date] = status;
      _students[i] = _students[i].copyWith(dateWiseRecord: map);
      notifyListeners();
      await _persistStudents();
    }
  }

  Future<void> markAllPresent(String date) async {
    for (int i = 0; i < _students.length; i++) {
      if (!_students[i].isDeleted) {
        final map = Map<String, String>.from(_students[i].dateWiseRecord);
        map[date] = 'P';
        _students[i] = _students[i].copyWith(dateWiseRecord: map);
      }
    }
    notifyListeners();
    await _persistStudents();
  }

  Future<void> lockDate(String date) async {
    _savedDates.add(date);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(AppConstants.savedDatesKey, _savedDates.toList());
    notifyListeners();
  }

  Future<void> unlockDate(String date) async {
    _savedDates.remove(date);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(AppConstants.savedDatesKey, _savedDates.toList());
    notifyListeners();
  }

  // ── Leaves ───────────────────────────────────────────────────────────────────

  Future<void> addLeave(LeaveRequest leave) async {
    _leaves.add(leave);
    notifyListeners();
    await _persistLeaves();
  }

  Future<void> updateLeaveStatus(String id, String status) async {
    final i = _leaves.indexWhere((l) => l.id == id);
    if (i != -1) {
      _leaves[i] = _leaves[i].copyWith(status: status);
      notifyListeners();
      await _persistLeaves();
    }
  }

  List<LeaveRequest> leavesForStudent(String studentId) =>
      _leaves.where((l) => l.studentId == studentId).toList();

  // ── CSV export ───────────────────────────────────────────────────────────────

  String generateCsv(String date) {
    final buf = StringBuffer('Name,Reg No,Class,Status\n');
    for (final s in students) {
      buf.writeln('${s.name},${s.regNo},${s.classSection},${s.statusForDate(date)}');
    }
    return buf.toString();
  }

  // Weekly stats: returns list of {date, present, absent} for last 7 days
  List<Map<String, dynamic>> weeklyStats() {
    final result = <Map<String, dynamic>>[];
    for (int i = 6; i >= 0; i--) {
      final day = DateTime.now().subtract(Duration(days: i));
      final key = _dateKey(day);
      int p = 0, a = 0;
      for (final s in students) {
        final st = s.statusForDate(key);
        if (st == 'P') p++;
        if (st == 'A') a++;
      }
      result.add({'date': day, 'present': p, 'absent': a});
    }
    return result;
  }

  // ── Defaults ─────────────────────────────────────────────────────────────────

  List<Student> _defaultStudents() {
    Map<String, String> rec(List<String> s) {
      final map = <String, String>{};
      for (int i = 0; i < s.length; i++) {
        final d = DateTime.now().subtract(Duration(days: s.length - 1 - i));
        map[_dateKey(d)] = s[i];
      }
      return map;
    }

    return [
      Student(id: '1', name: 'Ali Hassan', regNo: 'REG-001', classSection: '10-A', phone: '0300-1234001', email: 'ali@school.com', imagePath: 'assets/images/ali.jpeg', isAsset: true, dateWiseRecord: rec(['P', 'P', 'A', 'P', 'P', 'A', 'P'])),
      Student(id: '2', name: 'Sara Khan', regNo: 'REG-002', classSection: '10-A', phone: '0300-1234002', email: 'student@school.com', imagePath: 'assets/images/sara.jpeg', isAsset: true, dateWiseRecord: rec(['P', 'A', 'P', 'P', 'A', 'P', 'P'])),
      Student(id: '3', name: 'Ahmed Ali', regNo: 'REG-003', classSection: '10-B', phone: '0300-1234003', email: 'ahmed@school.com', imagePath: 'assets/images/ahmed.jpeg', isAsset: true, dateWiseRecord: rec(['A', 'P', 'A', 'P', 'P', 'A', 'A'])),
    ];
  }

  List<LeaveRequest> _defaultLeaves() => const [
        LeaveRequest(id: 'L1', studentId: '1', studentName: 'Ali Hassan', studentImagePath: 'assets/images/ali.jpeg', studentIsAsset: true, type: 'Sick Leave', reason: 'Fever and flu', startDate: '2024-05-10', endDate: '2024-05-11', status: 'Pending'),
        LeaveRequest(id: 'L2', studentId: '2', studentName: 'Sara Khan', studentImagePath: 'assets/images/sara.jpeg', studentIsAsset: true, type: 'Family Event', reason: 'Family wedding ceremony', startDate: '2024-05-12', endDate: '2024-05-12', status: 'Approved'),
      ];
}
