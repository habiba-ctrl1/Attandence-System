// lib/features/admin/attendance_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../models/student.dart';
import '../../providers/app_provider.dart';
import '../../widgets/student_avatar.dart';
import '../../widgets/empty_state.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});
  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  DateTime _selectedDate = DateTime.now();
  // Undo stack: {studentId, prevStatus}
  final List<Map<String, String>> _undoStack = [];

  String get _dateKey => DateFormat('yyyy-MM-dd').format(_selectedDate);
  bool get _isToday => _dateKey == DateFormat('yyyy-MM-dd').format(DateTime.now());

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _mark(AppProvider ap, Student s, String status) async {
    final prev = s.statusForDate(_dateKey);
    _undoStack.add({'id': s.id, 'prev': prev});
    await ap.markAttendance(s.id, _dateKey, status);
  }

  Future<void> _undo(AppProvider ap) async {
    if (_undoStack.isEmpty) return;
    final last = _undoStack.removeLast();
    await ap.markAttendance(last['id']!, _dateKey, last['prev']!);
    setState(() {});
  }

  Future<void> _saveDate(AppProvider ap) async {
    await ap.lockDate(_dateKey);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Attendance saved and locked'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final ap = context.watch<AppProvider>();
    final students = ap.students;
    final locked = ap.isDateSaved(_dateKey);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        title: const Text('Attendance Sheet'),
        actions: [
          if (_undoStack.isNotEmpty)
            TextButton.icon(
              onPressed: () => _undo(ap),
              icon: const Icon(Icons.undo, color: Colors.white),
              label: const Text('Undo', style: TextStyle(color: Colors.white)),
            ),
          if (locked)
            IconButton(
              icon: const Icon(Icons.lock_open),
              tooltip: 'Unlock for editing',
              onPressed: () => ap.unlockDate(_dateKey),
            ),
        ],
      ),
      body: Column(
        children: [
          _dateBar(locked),
          if (!locked) _bulkBar(ap),
          Expanded(
            child: students.isEmpty
                ? const EmptyState(message: 'No students enrolled')
                : ListView.builder(
                    itemCount: students.length,
                    padding: const EdgeInsets.only(bottom: 90),
                    itemBuilder: (ctx, i) =>
                        _tile(students[i], ap, locked),
                  ),
          ),
        ],
      ),
      floatingActionButton: locked
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _saveDate(ap),
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.save),
              label: const Text('Save & Lock'),
            ),
    );
  }

  // ── Date picker bar ──────────────────────────────────────────────────────────

  Widget _dateBar(bool locked) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Row(children: [
          const Icon(Icons.calendar_month, size: 20),
          const SizedBox(width: 8),
          Text(
            DateFormat('EEEE, dd MMM yyyy').format(_selectedDate),
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          if (_isToday)
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                  color: AppConstants.primaryColor,
                  borderRadius: BorderRadius.circular(8)),
              child: const Text('Today',
                  style: TextStyle(color: Colors.white, fontSize: 11)),
            ),
          const Spacer(),
          if (locked)
            const Icon(Icons.lock, size: 18, color: Colors.grey),
          TextButton(
            onPressed: _pickDate,
            child: const Text('Change'),
          ),
        ]),
      );

  Widget _bulkBar(AppProvider ap) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => ap.markAllPresent(_dateKey),
              icon: const Icon(Icons.done_all, size: 18, color: Colors.green),
              label: const Text('All Present',
                  style: TextStyle(color: Colors.green, fontSize: 13)),
              style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.green)),
            ),
          ),
        ]),
      );

  // ── Student tile ─────────────────────────────────────────────────────────────

  Widget _tile(Student s, AppProvider ap, bool locked) {
    final status = s.statusForDate(_dateKey);

    Color cardColor;
    if (status == 'P') {
      cardColor = Colors.green.shade50;
    } else if (status == 'A') {
      cardColor = Colors.red.shade50;
    } else {
      cardColor = Theme.of(context).cardColor;
    }

    return Card(
      color: cardColor,
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(children: [
          StudentAvatar(student: s, radius: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.name,
                    style:
                        const TextStyle(fontWeight: FontWeight.w600)),
                Text('${s.regNo}  •  ${s.classSection}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          // Status chip
          _statusChip(status),
          const SizedBox(width: 8),
          // Buttons
          if (!locked) ...[
            _markBtn(Icons.check_circle_outline, Colors.green, 'P',
                status == 'P', () => _mark(ap, s, 'P')),
            _markBtn(Icons.cancel_outlined, Colors.red, 'A',
                status == 'A', () => _mark(ap, s, 'A')),
          ],
        ]),
      ),
    );
  }

  Widget _statusChip(String status) {
    Color color;
    String label;
    switch (status) {
      case 'P':
        color = Colors.green;
        label = 'Present';
        break;
      case 'A':
        color = Colors.red;
        label = 'Absent';
        break;
      default:
        color = Colors.grey;
        label = 'Unmarked';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }

  Widget _markBtn(IconData icon, Color color, String status, bool active,
          VoidCallback onTap) =>
      IconButton(
        icon: Icon(icon,
            color: active ? color : Colors.grey.shade300, size: 26),
        onPressed: onTap,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      );
}
