// lib/features/admin/admin_dashboard.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constants.dart';
import '../../models/student.dart';
import '../../providers/app_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/student_avatar.dart';
import '../../widgets/empty_state.dart';
import '../auth/login_page.dart';
import '../settings/settings_page.dart';
import 'add_edit_student_page.dart';
import 'student_profile_page.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});
  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Logout ───────────────────────────────────────────────────────────────────

  void _logout() => showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            ElevatedButton(
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.red),
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

  // ── CSV Export ───────────────────────────────────────────────────────────────

  Future<void> _exportCsv() async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final csv = context.read<AppProvider>().generateCsv(today);
    try {
      await Share.share(csv, subject: 'Attendance Report - $today');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Export failed: $e')));
      }
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final ap = context.watch<AppProvider>();
    final tp = context.watch<ThemeProvider>();

    final filtered = ap.students
        .where((s) =>
            s.name.toLowerCase().contains(_query.toLowerCase()) ||
            s.regNo.toLowerCase().contains(_query.toLowerCase()) ||
            s.classSection.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tp.schoolName,
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const Text('Admin Panel',
                style: TextStyle(fontSize: 11, color: Colors.white70)),
          ],
        ),
        actions: [
          IconButton(
              icon: const Icon(Icons.file_download_outlined),
              onPressed: _exportCsv,
              tooltip: 'Export CSV'),
          IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SettingsPage())),
              tooltip: 'Settings'),
          IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logout,
              tooltip: 'Logout'),
        ],
      ),
      body: ap.isLoading
          ? _shimmer()
          : RefreshIndicator(
              onRefresh: ap.loadData,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _statsBar(ap)),
                  SliverToBoxAdapter(child: _searchBar()),
                  SliverToBoxAdapter(child: _bulkActions(ap)),
                  filtered.isEmpty
                      ? const SliverFillRemaining(
                          child: EmptyState(
                            message: 'No students found',
                            subMessage:
                                'Add a student using the button below',
                          ),
                        )
                      : SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (ctx, i) =>
                                _studentTile(ctx, filtered[i], ap),
                            childCount: filtered.length,
                          ),
                        ),
                  const SliverToBoxAdapter(child: SizedBox(height: 90)),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddEditStudentPage()),
        ),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add),
        label: const Text('Add Student'),
      ),
    );
  }

  // ── Stats bar ────────────────────────────────────────────────────────────────

  Widget _statsBar(AppProvider ap) {
    final items = [
      _StatItem('Total', '${ap.students.length}', Icons.group, Colors.white),
      _StatItem('Present', '${ap.presentTodayCount}', Icons.check_circle,
          Colors.greenAccent.shade200),
      _StatItem('Absent', '${ap.absentTodayCount}', Icons.cancel,
          Colors.red.shade200),
      _StatItem('Leaves', '${ap.pendingLeavesCount}', Icons.mail,
          Colors.orange.shade200),
    ];
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [AppConstants.primaryDark, AppConstants.primaryColor, AppConstants.primaryLight]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: AppConstants.primaryColor.withValues(alpha: 0.35),
              blurRadius: 14,
              offset: const Offset(0, 6))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0) Container(height: 36, width: 1, color: Colors.white30),
            _statCell(items[i]),
          ]
        ],
      ),
    );
  }

  Widget _statCell(_StatItem item) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(item.icon, color: item.color, size: 20),
          const SizedBox(height: 4),
          Text(item.value,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18)),
          Text(item.label,
              style:
                  const TextStyle(color: Colors.white70, fontSize: 10)),
        ],
      );

  // ── Search bar ───────────────────────────────────────────────────────────────

  Widget _searchBar() => Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
        child: TextField(
          controller: _searchCtrl,
          onChanged: (v) => setState(() => _query = v),
          decoration: InputDecoration(
            hintText: 'Search by name, reg no, class…',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _query.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchCtrl.clear();
                      setState(() => _query = '');
                    })
                : null,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14)),
            contentPadding: const EdgeInsets.symmetric(vertical: 0),
          ),
        ),
      );

  // ── Bulk actions ─────────────────────────────────────────────────────────────

  Widget _bulkActions(AppProvider ap) {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: OutlinedButton.icon(
        onPressed: () async {
          await ap.markAllPresent(today);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('All students marked Present for today'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ));
          }
        },
        icon: const Icon(Icons.done_all, color: Colors.green),
        label: const Text('Mark All Present Today',
            style: TextStyle(color: Colors.green)),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.green),
          padding: const EdgeInsets.symmetric(vertical: 10),
          minimumSize: const Size(double.infinity, 0),
        ),
      ),
    );
  }

  // ── Student tile ─────────────────────────────────────────────────────────────

  Widget _studentTile(BuildContext ctx, Student s, AppProvider ap) {
    final low = s.percentage < AppConstants.lowAttendanceThreshold &&
        s.dateWiseRecord.isNotEmpty;
    return Dismissible(
      key: Key('student_${s.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        color: Colors.red,
        padding: const EdgeInsets.only(right: 22),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (_) => showDialog<bool>(
        context: ctx,
        builder: (d) => AlertDialog(
          title: const Text('Remove Student?'),
          content: Text('Remove ${s.name} from the list?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(d, false),
                child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(d, true),
              child: const Text('Remove',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
      onDismissed: (_) async {
        await ap.softDeleteStudent(s.id);
        if (ctx.mounted) {
          ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
            content: Text('${s.name} removed'),
            action: SnackBarAction(label: 'Undo', onPressed: ap.undoDelete),
            backgroundColor: Colors.grey[800],
            behavior: SnackBarBehavior.floating,
          ));
        }
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: low
              ? const BorderSide(color: Colors.red, width: 1.5)
              : BorderSide.none,
        ),
        child: ListTile(
          onTap: () => Navigator.push(
            ctx,
            MaterialPageRoute(
                builder: (_) => StudentProfilePage(student: s)),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          leading: StudentAvatar(
              student: s,
              radius: 24,
              heroTag: 'student_${s.id}'),
          title: Row(children: [
            Expanded(
                child: Text(s.name,
                    style:
                        const TextStyle(fontWeight: FontWeight.w600))),
            if (low)
              const Tooltip(
                message: 'Low attendance',
                child: Icon(Icons.warning_amber_rounded,
                    color: Colors.orange, size: 16),
              ),
          ]),
          subtitle: Text('${s.regNo}  •  ${s.classSection}',
              style: const TextStyle(fontSize: 12)),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${s.percentage.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: low ? Colors.red : Colors.green,
                ),
              ),
              const Text('attendance',
                  style: TextStyle(fontSize: 9, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  // ── Shimmer ──────────────────────────────────────────────────────────────────

  Widget _shimmer() => Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: ListView.builder(
          itemCount: 6,
          padding: const EdgeInsets.all(16),
          itemBuilder: (_, __) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            height: 68,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14)),
          ),
        ),
      );
}

class _StatItem {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatItem(this.label, this.value, this.icon, this.color);
}
