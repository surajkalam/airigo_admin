// models/issue_report_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminIssuereport {
  final String id;
  final String? jobseekerEmail;
  final String? jobseekerName;
  final String? recruiterEmail;
  final String? recruiterName;
  final String type; // 'issue' or 'report'
  final String title;
  final String description;
  final String status; // 'pending', 'in_progress', 'resolved'
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? adminResponse;

  // Computed properties for easier access
  String get userEmail => jobseekerEmail ?? recruiterEmail ?? '';
  String get userName => jobseekerName ?? recruiterName ?? '';
  String get userType => jobseekerEmail != null ? 'jobseeker' : 'recruiter';

  AdminIssuereport({
    required this.id,
    this.jobseekerEmail,
    this.jobseekerName,
    this.recruiterEmail,
    this.recruiterName,
    required this.type,
    required this.title,
    required this.description,
    this.status = 'pending',
    required this.createdAt,
    this.updatedAt,
    this.adminResponse,
  });

  Map<String, dynamic> toMap() {
    return {
      'jobseekerEmail': jobseekerEmail,
      'jobseekerName': jobseekerName,
      'type': type,
      'title': title,
      'description': description,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'adminResponse': adminResponse,
    };
  }

  factory AdminIssuereport.fromMap(String id, Map<String, dynamic> map) {
    return AdminIssuereport(
      id: id,
      jobseekerEmail: map['jobseekerEmail']?.toString(),
      jobseekerName: map['jobseekerName']?.toString(),
      recruiterEmail: map['recruiterEmail']?.toString(),
      recruiterName: map['recruiterName']?.toString(),
      type: map['type'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      status: map['status'] ?? 'pending',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
      adminResponse: map['adminResponse'],
    );
  }
}