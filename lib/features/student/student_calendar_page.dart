// lib/features/student/student_calendar_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/constants.dart';
import '../../models/student.dart';
import '../../providers/app_provider.dart';
import '../../widgets/empty_state.dart';

class StudentCalendarPage extends StatefulWidget {
  const StudentCalendarPage({super.key});
  @override
  State<StudentCalendarPage> createState() => _StudentCalendarPageState();
}

class _StudentCalendarPageState extends State<StudentCalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  String _key(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  @override
  Widget build(BuildContext context) {
    final ap = context.watch<AppProvider>();
    final s = ap.loggedInStudent;

    if (s == null) {
      return const Scaffold(
          body: EmptyState(message: 'Student not found'));
    }

    final selectedKey =
        _selectedDay != null ? _key(_selectedDay!) : null;
    final selectedStatus =
        selectedKey != null ? s.statusForDate(selectedKey) : null;

    // Monthly stats
    final monthEntries = s.dateWiseRecord.entries
        .where((e) {
          try {
            final d = DateTime.parse(e.key);
            return d.year == _focusedDay.year &&
                d.month == _focusedDay.month;
          } catch (_) {
            return false;
          }
        })
        .toList();

    final monthPresent =
        monthEntries.where((e) => e.value == 'P').length;
    final monthAbsent =
        monthEntries.where((e) => e.value == 'A').length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        title: const Text('Attendance Calendar'),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2023, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: CalendarFormat.month,
            selectedDayPredicate: (d) => isSameDay(_selectedDay, d),
            onDaySelected: (sel, foc) =>
                setState(() {
                  _selectedDay = sel;
                  _focusedDay = foc;
                }),
            onPageChanged: (foc) => setState(() => _focusedDay = foc),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16),
            ),
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: AppConstants.primaryColor.withValues(alpha: 0.25),
                shape: BoxShape.circle,
              ),
              selectedDecoration: const BoxDecoration(
                color: AppConstants.primaryColor,
                shape: BoxShape.circle,
              ),
            ),
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (ctx, day, focused) =>
                  _dayCell(s, day, false),
              outsideBuilder: (ctx, day, focused) =>
                  _dayCell(s, day, true),
              todayBuilder: (ctx, day, focused) =>
                  _dayCell(s, day, false, isToday: true),
            ),
          ),
          // Legend
          _legend(),
          const Divider(height: 1),
          // Monthly summary
          _monthlySummary(monthPresent, monthAbsent),
          // Selected day detail
          if (_selectedDay != null && selectedStatus != null) ...[
            const Divider(height: 1),
            _selectedDayDetail(_selectedDay!, selectedStatus),
          ],
        ],
      ),
    );
  }

  Widget _dayCell(Student s, DateTime day, bool outside,
      {bool isToday = false}) {
    final key = _key(day);
    final status = s.statusForDate(key);
    Color? bgColor;
    Color textColor = outside ? Colors.grey.shade400 : Colors.black87;

    if (status == 'P') {
      bgColor = Colors.green.shade100;
      textColor = Colors.green.shade800;
    } else if (status == 'A') {
      bgColor = Colors.red.shade100;
      textColor = Colors.red.shade800;
    }

    if (isToday && bgColor == null) {
      bgColor = AppConstants.primaryColor.withValues(alpha: 0.15);
    }

    return Container(
      margin: const EdgeInsets.all(3),
      decoration: bgColor != null
          ? BoxDecoration(color: bgColor, shape: BoxShape.circle)
          : null,
      child: Center(
        child: Text(
          '${day.day}',
          style: TextStyle(
            fontSize: 13,
            color: textColor,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _legend() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _legendItem(Colors.green.shade100, Colors.green.shade800, 'Present'),
            const SizedBox(width: 20),
            _legendItem(Colors.red.shade100, Colors.red.shade800, 'Absent'),
            const SizedBox(width: 20),
            _legendItem(Colors.grey.shade200, Colors.grey.shade600, 'Unmarked'),
          ],
        ),
      );

  Widget _legendItem(Color bg, Color text, String label) => Row(children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
          child: Center(
              child: Text('A',
                  style: TextStyle(
                      fontSize: 10,
                      color: text,
                      fontWeight: FontWeight.bold))),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ]);

  Widget _monthlySummary(int present, int absent) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _summaryChip(
                '${DateFormat('MMMM').format(_focusedDay)} Summary',
                null,
                Colors.grey),
            _summaryChip('$present', 'Present', Colors.green),
            _summaryChip('$absent', 'Absent', Colors.red),
          ],
        ),
      );

  Widget _summaryChip(String value, String? label, Color color) => Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: label == null ? 13 : 18,
                  fontWeight: FontWeight.bold,
                  color: color)),
          if (label != null)
            Text(label,
                style:
                    const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      );

  Widget _selectedDayDetail(DateTime day, String status) {
    Color color;
    IconData icon;
    String text;
    switch (status) {
      case 'P':
        color = Colors.green;
        icon = Icons.check_circle;
        text = 'Present';
        break;
      case 'A':
        color = Colors.red;
        icon = Icons.cancel;
        text = 'Absent';
        break;
      default:
        color = Colors.grey;
        icon = Icons.help_outline;
        text = 'Not Marked';
    }
    return Container(
      padding: const EdgeInsets.all(14),
      color: color.withValues(alpha: 0.05),
      child: Row(children: [
        Icon(icon, color: color),
        const SizedBox(width: 10),
        Text(
          '${DateFormat('dd MMM yyyy').format(day)}  —  $text',
          style: TextStyle(color: color, fontWeight: FontWeight.w600),
        ),
      ]),
    );
  }
}
