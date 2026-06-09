// lib/features/admin/stats_page.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../models/student.dart';
import '../../providers/app_provider.dart';
import '../../widgets/empty_state.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ap = context.watch<AppProvider>();
    final students = ap.students;

    if (students.isEmpty) {
      return const Scaffold(
        body: EmptyState(message: 'No data yet', subMessage: 'Add students to see stats'),
      );
    }

    final totalP = students.fold<int>(0, (s, e) => s + e.totalPresent);
    final totalA = students.fold<int>(0, (s, e) => s + e.totalAbsent);
    final avg = students.isEmpty
        ? 0.0
        : students.map((s) => s.percentage).reduce((a, b) => a + b) /
            students.length;

    final sorted = List<Student>.from(students)
      ..sort((a, b) => b.percentage.compareTo(a.percentage));
    final top = sorted.first;
    final worst = sorted.last;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        title: const Text('Performance Statistics'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Lottie header
          Center(
            child: Lottie.asset('assets/animations/app.json', height: 110,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.analytics, size: 80, color: Colors.grey)),
          ),
          const SizedBox(height: 8),
          // Summary cards
          Row(children: [
            _summaryCard('Class Avg', '${avg.toStringAsFixed(1)}%',
                Icons.school, Colors.blue),
            const SizedBox(width: 12),
            _summaryCard(
                'Total Students', '${students.length}', Icons.group, Colors.purple),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            _summaryCard(
                'Total Present', '$totalP', Icons.check_circle, Colors.green),
            const SizedBox(width: 12),
            _summaryCard('Total Absent', '$totalA', Icons.cancel, Colors.red),
          ]),
          const SizedBox(height: 20),
          // Highlights
          _highlights(top, worst),
          const SizedBox(height: 20),
          // Pie chart
          _sectionTitle('Present vs Absent'),
          const SizedBox(height: 8),
          _pieChart(totalP.toDouble(), totalA.toDouble()),
          const SizedBox(height: 24),
          // Bar chart
          _sectionTitle('Weekly Attendance Trend'),
          const SizedBox(height: 8),
          _barChart(ap),
          const SizedBox(height: 24),
          // Per-student list
          _sectionTitle('Per Student Progress'),
          const SizedBox(height: 8),
          ...students.map((s) => _studentRow(s)),
        ],
      ),
    );
  }

  Widget _summaryCard(String label, String value, IconData icon, Color color) =>
      Expanded(
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(value,
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold, color: color)),
              Text(label,
                  style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ]),
          ]),
        ),
      );

  Widget _highlights(Student top, Student worst) => Row(children: [
        Expanded(
          child: _highlightCard('Top Performer', top.name,
              '${top.percentage.toStringAsFixed(0)}%', Colors.green,
              Icons.emoji_events),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _highlightCard('Needs Attention', worst.name,
              '${worst.percentage.toStringAsFixed(0)}%', Colors.orange,
              Icons.warning_amber_rounded),
        ),
      ]);

  Widget _highlightCard(String title, String name, String pct, Color color,
      IconData icon) =>
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [color.withValues(alpha: 0.15), color.withValues(alpha: 0.05)]),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(title,
                style: TextStyle(
                    fontSize: 11, color: color, fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 4),
          Text(name,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis),
          Text(pct, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        ]),
      );

  Widget _sectionTitle(String t) => Text(t,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold));

  Widget _pieChart(double present, double absent) {
    if (present == 0 && absent == 0) {
      return const Center(child: Text('No attendance data yet'));
    }
    final total = present + absent;
    return SizedBox(
      height: 200,
      child: Row(children: [
        Expanded(
          child: PieChart(PieChartData(
            sectionsSpace: 3,
            centerSpaceRadius: 45,
            sections: [
              PieChartSectionData(
                color: Colors.green,
                value: present,
                title: '${(present / total * 100).toStringAsFixed(0)}%',
                radius: 55,
                titleStyle: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              PieChartSectionData(
                color: Colors.red,
                value: absent,
                title: '${(absent / total * 100).toStringAsFixed(0)}%',
                radius: 55,
                titleStyle: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          )),
        ),
        const SizedBox(width: 16),
        Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          _legend(Colors.green, 'Present'),
          const SizedBox(height: 8),
          _legend(Colors.red, 'Absent'),
        ]),
        const SizedBox(width: 8),
      ]),
    );
  }

  Widget _legend(Color color, String label) => Row(children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ]);

  Widget _barChart(AppProvider ap) {
    final weekly = ap.weeklyStats();
    final maxY =
        weekly.fold<int>(0, (m, e) => (e['present'] as int) + (e['absent'] as int) > m
                ? (e['present'] as int) + (e['absent'] as int)
                : m)
            .toDouble();

    return SizedBox(
      height: 180,
      child: BarChart(BarChartData(
        maxY: maxY == 0 ? 5 : maxY + 1,
        barTouchData: BarTouchData(enabled: false),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          show: true,
          leftTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, _) {
                final idx = v.toInt();
                if (idx < 0 || idx >= weekly.length) return const SizedBox();
                final date = weekly[idx]['date'] as DateTime;
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(DateFormat('E').format(date),
                      style: const TextStyle(fontSize: 10)),
                );
              },
            ),
          ),
        ),
        barGroups: [
          for (int i = 0; i < weekly.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: (weekly[i]['present'] as int).toDouble(),
                  color: Colors.green,
                  width: 14,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            ),
        ],
      )),
    );
  }

  Widget _studentRow(Student s) {
    final low = s.percentage < AppConstants.lowAttendanceThreshold &&
        s.dateWiseRecord.isNotEmpty;
    final color = low ? Colors.red : (s.percentage >= 90 ? Colors.green : Colors.blue);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: low
            ? Colors.red.withValues(alpha: 0.05)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: low
              ? Colors.red.withValues(alpha: 0.3)
              : Colors.grey.withValues(alpha: 0.2),
        ),
      ),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(s.name,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              if (low) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6)),
                  child: const Text('LOW',
                      style: TextStyle(
                          color: Colors.red,
                          fontSize: 9,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ]),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: s.percentage / 100,
                minHeight: 7,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ]),
        ),
        const SizedBox(width: 12),
        Text(
          '${s.percentage.toStringAsFixed(0)}%',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 15, color: color),
        ),
      ]),
    );
  }
}
