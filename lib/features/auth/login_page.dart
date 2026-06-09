// lib/features/auth/login_page.dart
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../providers/app_provider.dart';
import '../../providers/theme_provider.dart';
import '../admin/admin_main.dart';
import '../student/student_main.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  late final AnimationController _animCtrl;

  @override
  void initState() {
    super.initState();
    _animCtrl =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 700))
          ..forward();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _loading = false);

    final email = _emailCtrl.text.trim().toLowerCase();
    final pass = _passCtrl.text;

    if (email == AppConstants.adminEmail && pass == AppConstants.adminPassword) {
      _go(const AdminMain());
    } else if (email == AppConstants.studentEmail &&
        pass == AppConstants.studentPassword) {
      final ap = context.read<AppProvider>();
      // Find matching student by email; fall back to Sara (id=2)
      final match = ap.students
          .where((s) => s.email.toLowerCase() == email)
          .toList();
      ap.setLoggedInStudent(
          match.isNotEmpty ? match.first.id : (ap.students.length > 1 ? ap.students[1].id : ap.students.first.id));
      _go(const StudentMain());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Invalid email or password'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _go(Widget page) => Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, a, __) => page,
          transitionsBuilder: (_, a, __, child) =>
              FadeTransition(opacity: a, child: child),
          transitionDuration: const Duration(milliseconds: 350),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final school = context.watch<ThemeProvider>().schoolName;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff0D47A1), Color(0xff1565C0), Color(0xff1E88E5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _animCtrl,
            child: LayoutBuilder(builder: (ctx, constraints) {
              final wide = constraints.maxWidth > 600;
              return Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: wide ? constraints.maxWidth * 0.2 : 24,
                    vertical: 20,
                  ),
                  child: Column(
                    children: [
                      Hero(
                        tag: 'app_logo',
                        child: Lottie.asset(
                          'assets/animations/app.json',
                          height: 170,
                          errorBuilder: (_, __, ___) => const Icon(
                              Icons.school_rounded,
                              size: 100,
                              color: Colors.white),
                        ),
                      ),
                      Text(school,
                          style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5)),
                      const Text('Smart Attendance System',
                          style:
                              TextStyle(fontSize: 13, color: Colors.white70)),
                      const SizedBox(height: 36),
                      _card(),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _card() => Container(
        padding: const EdgeInsets.all(26),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 24,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text('Welcome Back',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary)),
            const SizedBox(height: 2),
            Text('Sign in to continue',
                style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.outline)),
            const SizedBox(height: 22),
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: _dec('Email', Icons.email_outlined),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Email is required';
                if (!v.contains('@')) return 'Enter a valid email';
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _passCtrl,
              obscureText: _obscure,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _login(),
              decoration: _dec('Password', Icons.lock_outline).copyWith(
                suffixIcon: IconButton(
                  icon: Icon(
                      _obscure ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Password is required';
                if (v.length < 6) return 'Minimum 6 characters';
                return null;
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _loading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: _loading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5))
                    : const Text('Sign In',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 18),
            const Divider(),
            const SizedBox(height: 10),
            _hint('Admin', AppConstants.adminEmail, 'admin123'),
            const SizedBox(height: 5),
            _hint('Student', AppConstants.studentEmail, 'student123'),
          ]),
        ),
      );

  InputDecoration _dec(String label, IconData icon) => InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppConstants.primaryColor),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppConstants.primaryColor, width: 2),
        ),
        filled: true,
        fillColor: AppConstants.bgPink.withValues(alpha: 0.4),
      );

  Widget _hint(String role, String email, String pass) => Row(children: [
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppConstants.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(role,
              style: const TextStyle(
                  fontSize: 11,
                  color: AppConstants.primaryColor,
                  fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 8),
        Expanded(
            child: Text('$email / $pass',
                style:
                    const TextStyle(fontSize: 11, color: Colors.grey))),
      ]);
}
