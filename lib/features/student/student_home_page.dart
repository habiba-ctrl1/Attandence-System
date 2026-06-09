// lib/features/student/student_home_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../models/student.dart';
import '../../providers/app_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/student_avatar.dart';
import '../auth/login_page.dart';
import '../settings/settings_page.dart';

class StudentHomePage extends StatelessWidget {
  const StudentHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ap = context.watch<AppProvider>();
    final tp = context.watch<ThemeProvider>();
    final s = ap.loggedInStudent;

    if (s == null) {
      return const Scaffold(
          body: EmptyState(message: 'Student not found'));
    }

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final todayStatus = s.statusForDate(today);
    final low = s.percentage < AppConstants.lowAttendanceThreshold &&
        s.dateWiseRecord.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tp.schoolName,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.bold)),
            const Text('Student Portal',
                style: TextStyle(fontSize: 11, color: Colors.white70)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const SettingsPage())),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: ap.loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _profileCard(context, s, low),
              const SizedBox(height: 16),
              _todayCard(todayStatus),
              const SizedBox(height: 16),
              _statsRow(s, low),
              const SizedBox(height: 16),
              _recentHistory(s),
            ],
          ),
        ),
      ),
    );
  }

  void _logout(BuildContext context) => showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (_) => false);
              },
              child: const Text('Logout',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );

  Widget _profileCard(BuildContext ctx, Student s, bool low) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppConstants.primaryDark, AppConstants.primaryColor, AppConstants.primaryLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: AppConstants.primaryColor.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 6))
          ],
        ),
        child: Row(children: [
          StudentAvatar(student: s, radius: 34, heroTag: 'student_${s.id}'),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(s.name,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              Text('${s.regNo}  •  ${s.classSection}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 8),
              Row(children: [
                _badge(
                    '${s.percentage.toStringAsFixed(0)}%',
                    low ? Colors.red.shade300 : Colors.greenAccent.shade200),
                const SizedBox(width: 8),
                _badge(
                    s.percentage >= 75 ? 'SAFE' : 'LOW ATTENDANCE',
                    low ? Colors.red.shade300 : Colors.greenAccent.shade200),
              ]),
            ]),
          ),
        ]),
      );

  Widget _badge(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.6)),
        ),
        child: Text(text,
            style: TextStyle(
                color: color, fontSize: 11, fontWeight: FontWeight.bold)),
      );

  Widget _todayCard(String status) {
    Color color;
    IconData icon;
    String label;
    switch (status) {
      case 'P':
        color = Colors.green;
        icon = Icons.check_circle;
        label = 'Present Today';
        break;
      case 'A':
        color = Colors.red;
        icon = Icons.cancel;
        label = 'Absent Today';
        break;
      default:
        color = Colors.grey;
        icon = Icons.help_outline;
        label = 'Not Marked Yet';
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Today — ${DateFormat('dd MMM yyyy').format(DateTime.now())}',
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(label,
              style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.bold, color: color)),
        ]),
      ]),
    );
  }

  Widget _statsRow(Student s, bool low) => Row(children: [
        _statCard('Total Present', '${s.totalPresent}', Colors.green),
        const SizedBox(width: 12),
        _statCard('Total Absent', '${s.totalAbsent}', Colors.red),
        const SizedBox(width: 12),
        _statCard('Attendance %', '${s.percentage.toStringAsFixed(0)}%',
            low ? Colors.red : Colors.blue),
      ]);

  Widget _statCard(String label, String value, Color color) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.25)),
          ),
          child: Column(children: [
            Text(value,
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 2),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ]),
        ),
      );

  Widget _recentHistory(Student s) {
    if (s.dateWiseRecord.isEmpty) return const SizedBox.shrink();

    final sorted = s.dateWiseRecord.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));
    final recent = sorted.take(7).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Recent Attendance',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...recent.map((e) {
          final isP = e.value == 'P';
          return ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              radius: 14,
              backgroundColor:
                  isP ? Colors.green.shade100 : Colors.red.shade100,
              child: Icon(isP ? Icons.check : Icons.close,
                  size: 14, color: isP ? Colors.green : Colors.red),
            ),
            title: Text(_fmt(e.key), style: const TextStyle(fontSize: 13)),
            trailing: Text(
              isP ? 'Present' : 'Absent',
              style: TextStyle(
                  color: isP ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w600,
                  fontSize: 12),
            ),
          );
        }),
      ],
    );
  }

  String _fmt(String key) {
    try {
      return DateFormat('EEE, dd MMM').format(DateTime.parse(key));
    } catch (_) {
      return key;
    }
  }
}
