// lib/features/settings/settings_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../providers/theme_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tp = context.watch<ThemeProvider>();
    final s = tp.settings;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          _header('School'),
          ListTile(
            leading: const Icon(Icons.school, color: AppConstants.primaryColor),
            title: const Text('School Name'),
            subtitle: Text(s.schoolName),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _editSchoolName(context, s.schoolName, tp),
          ),
          const Divider(),
          _header('Appearance'),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode, color: AppConstants.primaryColor),
            title: const Text('Dark Mode'),
            subtitle: const Text('Switch between light and dark theme'),
            value: s.isDarkMode,
            activeThumbColor: AppConstants.primaryColor,
            onChanged: (_) => tp.toggleDark(),
          ),
          ListTile(
            leading: const Icon(Icons.text_fields, color: AppConstants.primaryColor),
            title: const Text('Font Size'),
            subtitle: Text('Current: ${s.fontSize.toStringAsFixed(0)}px'),
            trailing: SizedBox(
              width: 200,
              child: Slider(
                value: s.fontSize,
                min: 12,
                max: 18,
                divisions: 3,
                activeColor: AppConstants.primaryColor,
                label: '${s.fontSize.toStringAsFixed(0)}px',
                onChanged: tp.setFontSize,
              ),
            ),
          ),
          const Divider(),
          _header('About'),
          const ListTile(
            leading: Icon(Icons.info_outline, color: AppConstants.primaryColor),
            title: Text('App Version'),
            trailing: Text('2.0.0', style: TextStyle(color: Colors.grey)),
          ),
          const ListTile(
            leading: Icon(Icons.developer_board, color: AppConstants.primaryColor),
            title: Text('Developer'),
            trailing: Text('Smart Attendance',
                style: TextStyle(color: Colors.grey, fontSize: 12)),
          ),
          const Divider(),
          _header('Credentials (Demo)'),
          _credTile('Admin', AppConstants.adminEmail, 'admin123'),
          _credTile('Student', AppConstants.studentEmail, 'student123'),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _header(String t) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
        child: Text(t.toUpperCase(),
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade500,
                letterSpacing: 1.2)),
      );

  Widget _credTile(String role, String email, String pass) => ListTile(
        dense: true,
        leading: CircleAvatar(
          radius: 14,
          backgroundColor: AppConstants.primaryColor.withValues(alpha: 0.15),
          child: Text(role[0],
              style: const TextStyle(
                  fontSize: 12,
                  color: AppConstants.primaryColor,
                  fontWeight: FontWeight.bold)),
        ),
        title: Text(email, style: const TextStyle(fontSize: 13)),
        trailing: Text(pass,
            style: const TextStyle(color: Colors.grey, fontSize: 12)),
      );

  void _editSchoolName(
      BuildContext context, String current, ThemeProvider tp) {
    final ctrl = TextEditingController(text: current);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('School Name'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(
              labelText: 'Enter school name',
              border: OutlineInputBorder()),
          autofocus: true,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor),
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                tp.setSchoolName(ctrl.text.trim());
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
