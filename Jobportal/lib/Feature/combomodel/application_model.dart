// models/application_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ApplicationModel {
  final String id;
  final String jobseekerEmail;
  final String jobseekerName;
  final String resumeUrl;
  final String coverLetter;
  final DateTime appliedAt;
  final String status; // pending, shortlisted, rejected
  final String jobId;
  final String jobTitle;
   final String recruiterEmail;

  ApplicationModel({
    required this.id,
    required this.jobseekerEmail,
    required this.jobseekerName,
    required this.resumeUrl,
    required this.coverLetter,
    required this.appliedAt,
    required this.status,
    required this.jobId,
    required this.jobTitle,
    required this.recruiterEmail,
  });

  Map<String, dynamic> toMap() {
    return {
      'jobseekerEmail': jobseekerEmail,
      'jobseekerName': jobseekerName,
      'resumeUrl': resumeUrl,
      'coverLetter': coverLetter,
      'appliedAt': appliedAt,
      'status': status,
      'jobId': jobId,
      'jobTitle': jobTitle,
      'recruiterEmail': recruiterEmail,
    };
  }

  factory ApplicationModel.fromMap(String id, Map<String, dynamic> map) {
    return ApplicationModel(
      id: id,
      jobseekerEmail: map['jobseekerEmail'] ?? '',
      jobseekerName: map['jobseekerName'] ?? '',
      resumeUrl: map['resumeUrl'] ?? '',
      coverLetter: map['coverLetter'] ?? '',
      appliedAt: (map['appliedAt'] as Timestamp).toDate(),
      status: map['status'] ?? 'pending',
      jobId: map['jobId'] ?? '',
      jobTitle: map['jobTitle'] ?? '',
      recruiterEmail: map['recruiterEmail'] ?? '',
    );
  }

  ApplicationModel copyWith({
    String? status,
  }) {
    return ApplicationModel(
      id: id,
      jobseekerEmail: jobseekerEmail,
      jobseekerName: jobseekerName,
      resumeUrl: resumeUrl,
      coverLetter: coverLetter,
      appliedAt: appliedAt,
      status: status ?? this.status,
      jobId: jobId,
      jobTitle: jobTitle,
      recruiterEmail: recruiterEmail,
    );
  }
}