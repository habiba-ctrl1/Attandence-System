// lib/features/admin/add_edit_student_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../models/student.dart';
import '../../providers/app_provider.dart';
import '../../widgets/student_avatar.dart';

class AddEditStudentPage extends StatefulWidget {
  final Student? student; // null = add mode
  const AddEditStudentPage({this.student, super.key});

  @override
  State<AddEditStudentPage> createState() => _AddEditStudentPageState();
}

class _AddEditStudentPageState extends State<AddEditStudentPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _regCtrl;
  late final TextEditingController _classCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _emailCtrl;
  String? _pickedImagePath;
  bool _saving = false;

  bool get _isEdit => widget.student != null;

  @override
  void initState() {
    super.initState();
    final s = widget.student;
    _nameCtrl = TextEditingController(text: s?.name ?? '');
    _regCtrl = TextEditingController(text: s?.regNo ?? '');
    _classCtrl = TextEditingController(text: s?.classSection ?? '');
    _phoneCtrl = TextEditingController(text: s?.phone ?? '');
    _emailCtrl = TextEditingController(text: s?.email ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _regCtrl.dispose();
    _classCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final file =
          await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (file != null) setState(() => _pickedImagePath = file.path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not pick image: $e')),
        );
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final ap = context.read<AppProvider>();
    final id = _isEdit ? widget.student!.id : DateTime.now().millisecondsSinceEpoch.toString();

    // Image handling
    String? finalPath;
    bool finalIsAsset = false;
    if (_pickedImagePath != null) {
      finalPath = _pickedImagePath;
      finalIsAsset = false;
    } else if (_isEdit) {
      finalPath = widget.student!.imagePath;
      finalIsAsset = widget.student!.isAsset;
    }

    final student = Student(
      id: id,
      name: _nameCtrl.text.trim(),
      regNo: _regCtrl.text.trim(),
      classSection: _classCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      imagePath: finalPath,
      isAsset: finalIsAsset,
      dateWiseRecord:
          _isEdit ? widget.student!.dateWiseRecord : const {},
    );

    if (_isEdit) {
      await ap.updateStudent(student);
    } else {
      await ap.addStudent(student);
    }

    setState(() => _saving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_isEdit ? '${student.name} updated' : '${student.name} enrolled'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        title: Text(_isEdit ? 'Edit Student' : 'Enroll Student'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Avatar picker
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    _pickedImagePath != null
                        ? CircleAvatar(
                            radius: 50,
                            backgroundImage:
                                FileImage(File(_pickedImagePath!)),
                          )
                        : widget.student != null
                            ? StudentAvatar(
                                student: widget.student!, radius: 50)
                            : const CircleAvatar(
                                radius: 50,
                                backgroundColor: AppConstants.primaryColor,
                                child: Icon(Icons.person,
                                    size: 44, color: Colors.white),
                              ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppConstants.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt,
                          color: Colors.white, size: 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text('Tap to change photo',
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 24),
              _field(_nameCtrl, 'Full Name', Icons.person_outline,
                  required: true),
              _field(_regCtrl, 'Registration No', Icons.badge_outlined,
                  required: true),
              _field(_classCtrl, 'Class / Section',
                  Icons.class_outlined),
              _field(_phoneCtrl, 'Phone Number', Icons.phone_outlined,
                  type: TextInputType.phone),
              _field(_emailCtrl, 'Email', Icons.email_outlined,
                  type: TextInputType.emailAddress),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _saving
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5))
                      : Text(
                          _isEdit ? 'Update Student' : 'Enroll Student',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon,
      {bool required = false, TextInputType? type}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: ctrl,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppConstants.primaryColor),
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
                color: AppConstants.primaryColor, width: 2),
          ),
        ),
        validator: required
            ? (v) => (v == null || v.trim().isEmpty) ? '$label is required' : null
            : null,
      ),
    );
  }
}
