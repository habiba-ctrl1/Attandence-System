// lib/models/leave_request.dart

class LeaveRequest {
  final String id;
  final String studentId;
  final String studentName;
  final String studentImagePath;
  final bool studentIsAsset;
  final String type;
  final String reason;
  final String startDate; // "yyyy-MM-dd"
  final String endDate;
  final String status; // "Pending" | "Approved" | "Rejected"

  const LeaveRequest({
    required this.id,
    required this.studentId,
    required this.studentName,
    this.studentImagePath = '',
    this.studentIsAsset = false,
    required this.type,
    required this.reason,
    required this.startDate,
    required this.endDate,
    this.status = 'Pending',
  });

  LeaveRequest copyWith({
    String? id,
    String? studentId,
    String? studentName,
    String? studentImagePath,
    bool? studentIsAsset,
    String? type,
    String? reason,
    String? startDate,
    String? endDate,
    String? status,
  }) =>
      LeaveRequest(
        id: id ?? this.id,
        studentId: studentId ?? this.studentId,
        studentName: studentName ?? this.studentName,
        studentImagePath: studentImagePath ?? this.studentImagePath,
        studentIsAsset: studentIsAsset ?? this.studentIsAsset,
        type: type ?? this.type,
        reason: reason ?? this.reason,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        status: status ?? this.status,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'studentId': studentId,
        'studentName': studentName,
        'studentImagePath': studentImagePath,
        'studentIsAsset': studentIsAsset,
        'type': type,
        'reason': reason,
        'startDate': startDate,
        'endDate': endDate,
        'status': status,
      };

  factory LeaveRequest.fromJson(Map<String, dynamic> json) => LeaveRequest(
        id: json['id'] as String? ?? '',
        studentId: json['studentId'] as String? ?? '',
        studentName: json['studentName'] as String? ?? '',
        studentImagePath: json['studentImagePath'] as String? ?? '',
        studentIsAsset: json['studentIsAsset'] as bool? ?? false,
        type: json['type'] as String? ?? '',
        reason: json['reason'] as String? ?? '',
        startDate: json['startDate'] as String? ?? '',
        endDate: json['endDate'] as String? ?? '',
        status: json['status'] as String? ?? 'Pending',
      );
}
