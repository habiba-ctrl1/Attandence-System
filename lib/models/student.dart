// lib/models/student.dart

class Student {
  final String id;
  final String name;
  final String regNo;
  final String classSection;
  final String phone;
  final String email;
  final String? imagePath;
  final bool isAsset;
  final Map<String, String> dateWiseRecord; // "2024-05-10" -> "P" | "A" | "Unmarked"
  final bool isDeleted;

  const Student({
    required this.id,
    required this.name,
    required this.regNo,
    this.classSection = '',
    this.phone = '',
    this.email = '',
    this.imagePath,
    this.isAsset = false,
    this.dateWiseRecord = const {},
    this.isDeleted = false,
  });

  double get percentage {
    final records = dateWiseRecord.values
        .where((v) => v == 'P' || v == 'A')
        .toList();
    if (records.isEmpty) return 0.0;
    final present = records.where((e) => e == 'P').length;
    return (present / records.length) * 100;
  }

  int get totalPresent =>
      dateWiseRecord.values.where((v) => v == 'P').length;

  int get totalAbsent =>
      dateWiseRecord.values.where((v) => v == 'A').length;

  String statusForDate(String date) =>
      dateWiseRecord[date] ?? 'Unmarked';

  Student copyWith({
    String? id,
    String? name,
    String? regNo,
    String? classSection,
    String? phone,
    String? email,
    String? imagePath,
    bool? isAsset,
    Map<String, String>? dateWiseRecord,
    bool? isDeleted,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      regNo: regNo ?? this.regNo,
      classSection: classSection ?? this.classSection,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      imagePath: imagePath ?? this.imagePath,
      isAsset: isAsset ?? this.isAsset,
      dateWiseRecord: dateWiseRecord ?? this.dateWiseRecord,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'regNo': regNo,
        'classSection': classSection,
        'phone': phone,
        'email': email,
        'imagePath': imagePath,
        'isAsset': isAsset,
        'dateWiseRecord': dateWiseRecord,
        'isDeleted': isDeleted,
      };

  factory Student.fromJson(Map<String, dynamic> json) => Student(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        regNo: json['regNo'] as String? ?? '',
        classSection: json['classSection'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        email: json['email'] as String? ?? '',
        imagePath: json['imagePath'] as String?,
        isAsset: json['isAsset'] as bool? ?? false,
        dateWiseRecord:
            (json['dateWiseRecord'] as Map<String, dynamic>? ?? {})
                .map((k, v) => MapEntry(k, v as String)),
        isDeleted: json['isDeleted'] as bool? ?? false,
      );
}
