// lib/widgets/student_avatar.dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../models/student.dart';
import '../core/constants.dart';

class StudentAvatar extends StatelessWidget {
  final Student student;
  final double radius;
  final String? heroTag;

  const StudentAvatar({
    required this.student,
    this.radius = 24,
    this.heroTag,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final avatar = _buildAvatar();
    if (heroTag != null) return Hero(tag: heroTag!, child: avatar);
    return avatar;
  }

  Widget _buildAvatar() {
    if (student.imagePath != null && student.isAsset) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: AssetImage(student.imagePath!),
        onBackgroundImageError: (_, __) {},
        backgroundColor: AppConstants.primaryColor,
        child: null,
      );
    }
    if (student.imagePath != null && !student.isAsset) {
      final file = File(student.imagePath!);
      if (file.existsSync()) {
        return CircleAvatar(
          radius: radius,
          backgroundImage: FileImage(file),
          backgroundColor: AppConstants.primaryColor,
        );
      }
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppConstants.primaryColor,
      child: Text(
        student.name.isNotEmpty ? student.name[0].toUpperCase() : '?',
        style: TextStyle(
          color: Colors.white,
          fontSize: radius * 0.75,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Avatar for a leave request (may not have a full Student object)
class LeaveAvatar extends StatelessWidget {
  final String imagePath;
  final bool isAsset;
  final String fallbackName;
  final double radius;

  const LeaveAvatar({
    required this.imagePath,
    required this.isAsset,
    required this.fallbackName,
    this.radius = 24,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (imagePath.isNotEmpty && isAsset) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: AssetImage(imagePath),
        onBackgroundImageError: (_, __) {},
        backgroundColor: AppConstants.primaryColor,
      );
    }
    if (imagePath.isNotEmpty && !isAsset) {
      final file = File(imagePath);
      if (file.existsSync()) {
        return CircleAvatar(
          radius: radius,
          backgroundImage: FileImage(file),
          backgroundColor: AppConstants.primaryColor,
        );
      }
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppConstants.primaryColor,
      child: Text(
        fallbackName.isNotEmpty ? fallbackName[0].toUpperCase() : '?',
        style: TextStyle(color: Colors.white, fontSize: radius * 0.75, fontWeight: FontWeight.bold),
      ),
    );
  }
}
