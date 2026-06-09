// lib/features/admin/admin_main.dart
import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import 'admin_dashboard.dart';
import 'attendance_page.dart';
import 'manage_leaves_page.dart';
import 'stats_page.dart';

class AdminMain extends StatefulWidget {
  const AdminMain({super.key});
  @override
  State<AdminMain> createState() => _AdminMainState();
}

class _AdminMainState extends State<AdminMain> {
  int _idx = 0;

  static const _pages = [
    AdminDashboard(),
    AttendancePage(),
    ManageLeavesPage(),
    StatsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final pending = context.watch<AppProvider>().pendingLeavesCount;
    return Scaffold(
      body: IndexedStack(index: _idx, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _idx,
        onDestinationSelected: (i) => setState(() => _idx = i),
        destinations: [
          const NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: 'Dashboard'),
          const NavigationDestination(
              icon: Icon(Icons.fact_check_outlined),
              selectedIcon: Icon(Icons.fact_check),
              label: 'Attendance'),
          NavigationDestination(
            icon: badges.Badge(
              showBadge: pending > 0,
              badgeContent: Text('$pending',
                  style: const TextStyle(color: Colors.white, fontSize: 9)),
              child: const Icon(Icons.mail_outline),
            ),
            selectedIcon: const Icon(Icons.mail),
            label: 'Leaves',
          ),
          const NavigationDestination(
              icon: Icon(Icons.analytics_outlined),
              selectedIcon: Icon(Icons.analytics),
              label: 'Stats'),
        ],
      ),
    );
  }
}
