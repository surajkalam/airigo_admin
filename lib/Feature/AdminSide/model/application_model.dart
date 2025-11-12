// models/application_models.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jobapp/Feature/JobSeeker/modelclass/jobseeker_info.dart';
import 'package:jobapp/Feature/combomodel/jobupload_model.dart';

class JobseekerApplicationStats {
  final int totalApplications;
  final int pending;
  final int shortlisted;
  final int rejected;
  final int accepted;

  JobseekerApplicationStats({
    required this.totalApplications,
    required this.pending,
    required this.shortlisted,
    required this.rejected,
    required this.accepted,
  });

  factory JobseekerApplicationStats.zero() {
    return JobseekerApplicationStats(
      totalApplications: 0,
      pending: 0,
      shortlisted: 0,
      rejected: 0,
      accepted: 0,
    );
  }
}

class JobseekerDetailedInfo {
  final JobseekerModel jobseeker;
  final JobseekerApplicationStats stats;
  final List<JobApplication> applications;

  JobseekerDetailedInfo({
    required this.jobseeker,
    required this.stats,
    required this.applications,
  });
}

class JobApplication {
  final String applicationId;
  final String jobId;
  final String jobTitle;
  final String recruiterEmail;
  final String status;
  final DateTime appliedDate;
  final String? coverLetter;
  final String? resumeUrl;
  final JobModel? jobDetails;

  JobApplication({
    required this.applicationId,
    required this.jobId,
    required this.jobTitle,
    required this.recruiterEmail,
    required this.status,
    required this.appliedDate,
    this.coverLetter,
    this.resumeUrl,
    this.jobDetails,
  });

  factory JobApplication.fromMap(Map<String, dynamic> map) {
    return JobApplication(
      applicationId: map['applicationId'] ?? '',
      jobId: map['jobId'] ?? '',
      jobTitle: map['jobTitle'] ?? '',
      recruiterEmail: map['recruiterEmail'] ?? '',
      status: map['status'] ?? 'pending',
      appliedDate: map['appliedDate'] != null 
          ? (map['appliedDate'] as Timestamp).toDate()
          : DateTime.now(),
      coverLetter: map['coverLetter'],
      resumeUrl: map['resumeUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'applicationId': applicationId,
      'jobId': jobId,
      'jobTitle': jobTitle,
      'recruiterEmail': recruiterEmail,
      'status': status,
      'appliedDate': Timestamp.fromDate(appliedDate),
      'coverLetter': coverLetter,
      'resumeUrl': resumeUrl,
    };
  }
}