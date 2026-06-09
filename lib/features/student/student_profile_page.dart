// lib/features/student/student_profile_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../providers/app_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/student_avatar.dart';

class StudentProfilePage extends StatelessWidget {
  const StudentProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ap = context.watch<AppProvider>();
    final s = ap.loggedInStudent;

    if (s == null) {
      return const Scaffold(body: EmptyState(message: 'Student not found'));
    }

    final low = s.percentage < AppConstants.lowAttendanceThreshold &&
        s.dateWiseRecord.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        title: const Text('My Profile'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Gradient header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppConstants.primaryDark,
                    AppConstants.primaryColor,
                    AppConstants.primaryLight,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(children: [
                StudentAvatar(student: s, radius: 46, heroTag: 'student_${s.id}'),
                const SizedBox(height: 12),
                Text(s.name,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                Text('${s.regNo}  •  ${s.classSection}',
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 13)),
              ]),
            ),
            // Circular progress
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(children: [
                _circularProgress(s.percentage, low),
                const SizedBox(height: 8),
                Text(
                  s.percentage >= 75 ? 'Attendance is Safe' : 'Attendance is Low!',
                  style: TextStyle(
                    color: low ? Colors.red : Colors.green,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ]),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  _infoTile(Icons.badge_outlined, 'Registration No', s.regNo),
                  _infoTile(Icons.class_outlined, 'Class / Section', s.classSection),
                  _infoTile(Icons.email_outlined, 'Email', s.email),
                  _infoTile(Icons.phone_outlined, 'Phone', s.phone),
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _statBox('Present', '${s.totalPresent}', Colors.green),
                      _statBox('Absent', '${s.totalAbsent}', Colors.red),
                      _statBox(
                          'Attendance', '${s.percentage.toStringAsFixed(0)}%',
                          low ? Colors.red : Colors.blue),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circularProgress(double pct, bool low) {
    return SizedBox(
      width: 140,
      height: 140,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 140,
            height: 140,
            child: CircularProgressIndicator(
              value: pct / 100,
              strokeWidth: 12,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(
                  low ? Colors.red : Colors.green),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${pct.toStringAsFixed(0)}%',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: low ? Colors.red : Colors.green),
              ),
              const Text('Attendance',
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) =>
      value.isEmpty
          ? const SizedBox.shrink()
          : ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Icon(icon, size: 20, color: AppConstants.primaryColor),
              title:
                  Text(value, style: const TextStyle(fontSize: 14)),
              subtitle: Text(label,
                  style: const TextStyle(
                      fontSize: 11, color: Colors.grey)),
            );

  Widget _statBox(String label, String value, Color color) => Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color)),
          Text(label,
              style:
                  const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      );
}
