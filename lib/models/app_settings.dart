// lib/models/app_settings.dart

class AppSettings {
  final String schoolName;
  final bool isDarkMode;
  final double fontSize;

  const AppSettings({
    this.schoolName = 'My School',
    this.isDarkMode = false,
    this.fontSize = 14.0,
  });

  AppSettings copyWith({
    String? schoolName,
    bool? isDarkMode,
    double? fontSize,
  }) =>
      AppSettings(
        schoolName: schoolName ?? this.schoolName,
        isDarkMode: isDarkMode ?? this.isDarkMode,
        fontSize: fontSize ?? this.fontSize,
      );

  Map<String, dynamic> toJson() => {
        'schoolName': schoolName,
        'isDarkMode': isDarkMode,
        'fontSize': fontSize,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
        schoolName: json['schoolName'] as String? ?? 'My School',
        isDarkMode: json['isDarkMode'] as bool? ?? false,
        fontSize: (json['fontSize'] as num?)?.toDouble() ?? 14.0,
      );
}
