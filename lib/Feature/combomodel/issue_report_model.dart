// models/issue_report_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class IssueReport {
  final String id;
  final String jobseekerEmail;
  final String jobseekerName;
  final String type; // 'issue' or 'report'
  final String title;
  final String description;
  final String status; // 'pending', 'in_progress', 'resolved'
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? adminResponse;

  IssueReport({
    required this.id,
    required this.jobseekerEmail,
    required this.jobseekerName,
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

  factory IssueReport.fromMap(String id, Map<String, dynamic> map) {
    return IssueReport(
      id: id,
      jobseekerEmail: map['jobseekerEmail'] ?? '',
      jobseekerName: map['jobseekerName'] ?? '',
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