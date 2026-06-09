// lib/features/admin/manage_leaves_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../models/leave_request.dart';
import '../../providers/app_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/student_avatar.dart';

class ManageLeavesPage extends StatelessWidget {
  const ManageLeavesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
          title: const Text('Leave Management'),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Pending'),
              Tab(text: 'Approved'),
              Tab(text: 'Rejected'),
            ],
          ),
        ),
        body: const TabBarView(children: [
          _LeaveList(status: 'Pending'),
          _LeaveList(status: 'Approved'),
          _LeaveList(status: 'Rejected'),
        ]),
      ),
    );
  }
}

class _LeaveList extends StatelessWidget {
  final String status;
  const _LeaveList({required this.status});

  @override
  Widget build(BuildContext context) {
    final leaves = context
        .watch<AppProvider>()
        .leaves
        .where((l) => l.status == status)
        .toList();

    if (leaves.isEmpty) {
      return EmptyState(
        message: 'No $status leaves',
        subMessage: status == 'Pending' ? 'All caught up!' : null,
      );
    }

    return RefreshIndicator(
      onRefresh: () async {},
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: leaves.length,
        itemBuilder: (ctx, i) => _LeaveCard(leave: leaves[i]),
      ),
    );
  }
}

class _LeaveCard extends StatelessWidget {
  final LeaveRequest leave;
  const _LeaveCard({required this.leave});

  void _confirm(BuildContext context, String newStatus) {
    final action = newStatus == 'Approved' ? 'Approve' : 'Reject';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('$action Leave?'),
        content: Text(
            '$action the leave request from ${leave.studentName}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  newStatus == 'Approved' ? Colors.green : Colors.red,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              context
                  .read<AppProvider>()
                  .updateLeaveStatus(leave.id, newStatus);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Leave ${newStatus.toLowerCase()}'),
                backgroundColor:
                    newStatus == 'Approved' ? Colors.green : Colors.red,
                behavior: SnackBarBehavior.floating,
              ));
            },
            child: Text(action,
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPending = leave.status == 'Pending';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(children: [
              LeaveAvatar(
                imagePath: leave.studentImagePath,
                isAsset: leave.studentIsAsset,
                fallbackName: leave.studentName,
                radius: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(leave.studentName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    Text(leave.type,
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              _statusChip(leave.status),
            ]),
            const SizedBox(height: 10),
            // Reason
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(children: [
                const Icon(Icons.notes, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Expanded(child: Text(leave.reason, style: const TextStyle(fontSize: 13))),
              ]),
            ),
            const SizedBox(height: 8),
            // Date range
            Row(children: [
              const Icon(Icons.date_range, size: 15, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                leave.startDate == leave.endDate
                    ? leave.startDate
                    : '${leave.startDate}  →  ${leave.endDate}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ]),
            if (isPending) ...[
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _confirm(context, 'Rejected'),
                    icon: const Icon(Icons.close, color: Colors.red, size: 18),
                    label: const Text('Reject',
                        style: TextStyle(color: Colors.red)),
                    style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _confirm(context, 'Approved'),
                    icon: const Icon(Icons.check, color: Colors.white, size: 18),
                    label: const Text('Approve',
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green),
                  ),
                ),
              ]),
            ],
          ],
        ),
      ),
    );
  }

  Widget _statusChip(String status) {
    Color color;
    IconData icon;
    switch (status) {
      case 'Approved':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'Rejected':
        color = Colors.red;
        icon = Icons.cancel;
        break;
      default:
        color = Colors.orange;
        icon = Icons.hourglass_top;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Text(status,
            style: TextStyle(
                color: color, fontSize: 11, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}
