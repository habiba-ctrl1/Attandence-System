// lib/features/admin/student_profile_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../models/leave_request.dart';
import '../../models/student.dart';
import '../../providers/app_provider.dart';
import '../../widgets/student_avatar.dart';
import 'add_edit_student_page.dart';

class StudentProfilePage extends StatelessWidget {
  final Student student;
  const StudentProfilePage({required this.student, super.key});

  @override
  Widget build(BuildContext context) {
    // Always read fresh from provider
    final ap = context.watch<AppProvider>();
    final s = ap.students.firstWhere(
      (x) => x.id == student.id,
      orElse: () => student,
    );
    final leaves = ap.leavesForStudent(s.id);

    final low = s.percentage < AppConstants.lowAttendanceThreshold &&
        s.dateWiseRecord.isNotEmpty;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 230,
            pinned: true,
            backgroundColor: AppConstants.primaryColor,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => AddEditStudentPage(student: s)),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 50),
                    StudentAvatar(
                        student: s, radius: 44, heroTag: 'student_${s.id}'),
                    const SizedBox(height: 10),
                    Text(s.name,
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    Text('${s.regNo}  •  ${s.classSection}',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats row
                  _statsRow(s, low),
                  const SizedBox(height: 20),
                  // Contact info
                  _section('Contact Info'),
                  _infoTile(Icons.email_outlined, 'Email', s.email),
                  _infoTile(Icons.phone_outlined, 'Phone', s.phone),
                  const SizedBox(height: 20),
                  // Attendance history
                  _section('Attendance History'),
                  const SizedBox(height: 8),
                  if (s.dateWiseRecord.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: Text('No attendance records yet')),
                    )
                  else
                    ..._attendanceHistory(s),
                  const SizedBox(height: 20),
                  // Leave history
                  _section('Leave History'),
                  const SizedBox(height: 8),
                  if (leaves.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(
                          child: Text('No leave requests',
                              style: TextStyle(color: Colors.grey))),
                    )
                  else
                    ...leaves.map((l) => _leaveChip(l)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statsRow(Student s, bool low) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _statBox('Attendance',
              '${s.percentage.toStringAsFixed(1)}%',
              low ? Colors.red : Colors.green),
          _statBox('Present', '${s.totalPresent}', Colors.green),
          _statBox('Absent', '${s.totalAbsent}', Colors.red),
          _statBox(
              'Status', s.percentage >= 75 ? 'SAFE' : 'LOW', low ? Colors.red : Colors.green),
        ],
      );

  Widget _statBox(String label, String value, Color color) => Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          Text(label,
              style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      );

  Widget _section(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(title,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold)),
      );

  Widget _infoTile(IconData icon, String label, String value) => value.isEmpty
      ? const SizedBox.shrink()
      : ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          leading: Icon(icon, size: 20, color: AppConstants.primaryColor),
          title: Text(value, style: const TextStyle(fontSize: 13)),
          subtitle:
              Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        );

  List<Widget> _attendanceHistory(Student s) {
    final sorted = s.dateWiseRecord.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));
    return [
      SizedBox(
        height: 200,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: sorted.length,
          itemBuilder: (_, i) {
            final entry = sorted[i];
            final isP = entry.value == 'P';
            return ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                radius: 14,
                backgroundColor:
                    isP ? Colors.green.shade100 : Colors.red.shade100,
                child: Icon(
                  isP ? Icons.check : Icons.close,
                  size: 16,
                  color: isP ? Colors.green : Colors.red,
                ),
              ),
              title: Text(
                  _formatDate(entry.key),
                  style: const TextStyle(fontSize: 13)),
              trailing: Text(
                isP ? 'Present' : 'Absent',
                style: TextStyle(
                    color: isP ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w600,
                    fontSize: 12),
              ),
            );
          },
        ),
      ),
    ];
  }

  String _formatDate(String key) {
    try {
      final d = DateTime.parse(key);
      return DateFormat('EEE, dd MMM yyyy').format(d);
    } catch (_) {
      return key;
    }
  }

  Widget _leaveChip(LeaveRequest l) {
    Color color;
    switch (l.status) {
      case 'Approved':
        color = Colors.green;
        break;
      case 'Rejected':
        color = Colors.red;
        break;
      default:
        color = Colors.orange;
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(children: [
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.type,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            Text('${l.startDate}  •  ${l.reason}',
                style: const TextStyle(color: Colors.grey, fontSize: 11)),
          ],
        )),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8)),
          child: Text(l.status,
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 11)),
        ),
      ]),
    );
  }
}
