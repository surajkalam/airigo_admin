// Revised Implementation without collectionGroup . single file
//jobseeekr_repository

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobapp/Feature/combomodel/jobupload_model.dart';

final jobRepositoryProvider = Provider<JobRepository>((ref) => JobRepository());

// Stream provider to fetch all jobs for a recruiter (admin view)
final getAllJobsForRecruiterProvider =
    StreamProvider.family<List<JobModel>, String>((ref, recruiterEmail) {
  final repo = ref.watch(jobRepositoryProvider);
  return repo.getAllJobsForRecruiter(recruiterEmail);
});

class JobRepository {
  final FirebaseFirestore _firestore;
  JobRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  // Fetch all active jobs from all recruiters
  Stream<List<JobModel>> getActiveJobs() {
    try {
      // Alternative approach: Get all recruiters first, then their jobs
      return _firestore.collection('recruiters').snapshots().asyncMap((
        recruitersSnapshot,
      ) async {
        final allJobs = <JobModel>[];

        for (final recruiterDoc in recruitersSnapshot.docs) {
          try {
            final jobsSnapshot = await _firestore
                .collection('recruiters')
                .doc(recruiterDoc.id)
                .collection('jobs')
                .where('isActive', isEqualTo: true)
                .get();
            allJobs.addAll(
              jobsSnapshot.docs
                  .map((doc) => JobModel.fromMap(doc.id, doc.data()))
                  .toList(),
            );
          } catch (e) {
            log('Error fetching jobs for recruiter ${recruiterDoc.id}: $e');
          }
        }

        return allJobs;
      });
    } catch (e) {
      log('Error in getActiveJobs: $e');
      // Fallback: Return empty list
      return Stream.value([]);
    }
  }

  // Fetch all jobs for a specific recruiter (active and inactive) for admin
  Stream<List<JobModel>> getAllJobsForRecruiter(String recruiterEmail) {
    try {
      return _firestore
          .collection('recruiters')
          .doc(recruiterEmail)
          .collection('jobs')
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => JobModel.fromMap(doc.id, doc.data()))
                .toList(),
          );
    } catch (e) {
      log('Error in getAllJobsForRecruiter: $e');
      return Stream.value([]);
    }
  }

  // Update job status (activate/deactivate) for admin
  Future<void> updateJobStatus(
    String jobId,
    String recruiterEmail,
    bool isActive,
  ) async {
    try {
      await _firestore
          .collection('recruiters')
          .doc(recruiterEmail)
          .collection('jobs')
          .doc(jobId)
          .update({
            'isActive': isActive,
            'updatedAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      log('Error updating job status: $e');
      throw Exception('Failed to update job status: $e');
    }
  }

  // Activate all jobs for a recruiter
  Future<void> activateAllJobsForRecruiter(String recruiterEmail) async {
    try {
      final jobsSnapshot = await _firestore
          .collection('recruiters')
          .doc(recruiterEmail)
          .collection('jobs')
          .where('isActive', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (final doc in jobsSnapshot.docs) {
        batch.update(doc.reference, {
          'isActive': true,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
    } catch (e) {
      log('Error activating all jobs for recruiter $recruiterEmail: $e');
      throw Exception('Failed to activate all jobs: $e');
    }
  }

  // Stream<List<JobModel>> getJobsByCategory(String category) {
  //   try {
  //     return _firestore.collection('recruiters').snapshots().asyncMap((
  //       recruitersSnapshot,
  //     ) async {
  //       final categoryJobs = <JobModel>[];
  //       for (final recruiterDoc in recruitersSnapshot.docs) {
  //         try {
  //           final jobsSnapshot = await _firestore
  //               .collection('recruiters')
  //               .doc(recruiterDoc.id)
  //               .collection('jobs')
  //               .where('isActive', isEqualTo: true)
  //               .where('category', isEqualTo: category)
  //               .get();
  //           categoryJobs.addAll(
  //             jobsSnapshot.docs
  //                 .map((doc) => JobModel.fromMap(doc.id, doc.data()))
  //                 .toList(),
  //           );
  //         } catch (e) {
  //           log(
  //             'Error fetching category jobs for recruiter ${recruiterDoc.id}: $e',
  //           );
  //         }
  //       }

  //       return categoryJobs;
  //     });
  //   } catch (e) {
  //     log('Error in getJobsByCategory: $e');
  //     return Stream.value([]);
  //   }
  // }

  // // Add similar temporary implementations for other methods...
  // Stream<List<JobModel>> getJobsByLocation(String location) {
  //   try {
  //     return _firestore.collection('recruiters').snapshots().asyncMap((
  //       recruitersSnapshot,
  //     ) async {
  //       final locationJobs = <JobModel>[];

  //       for (final recruiterDoc in recruitersSnapshot.docs) {
  //         try {
  //           final jobsSnapshot = await _firestore
  //               .collection('recruiters')
  //               .doc(recruiterDoc.id)
  //               .collection('jobs')
  //               .where('isActive', isEqualTo: true)
  //               .where('location', isEqualTo: location)
  //               .get();

  //           locationJobs.addAll(
  //             jobsSnapshot.docs
  //                 .map((doc) => JobModel.fromMap(doc.id, doc.data()))
  //                 .toList(),
  //           );
  //         } catch (e) {
  //           log(
  //             'Error fetching location jobs for recruiter ${recruiterDoc.id}: $e',
  //           );
  //         }
  //       }

  //       return locationJobs;
  //     });
  //   } catch (e) {
  //     log('Error in getJobsByLocation: $e');
  //     return Stream.value([]);
  //   }
  // }

  // // Simple search without collectionGroup
  // Stream<List<JobModel>> searchJobs({required String query}) {
  //   if (query.isEmpty) {
  //     return getActiveJobs();
  //   }

  //   final searchTerm = query.toLowerCase();

  //   return getActiveJobs().map(
  //     (jobs) => jobs
  //         .where(
  //           (job) =>
  //               job.companyName.toLowerCase().contains(searchTerm) ||
  //               job.designation.toLowerCase().contains(searchTerm) ||
  //               job.location.toLowerCase().contains(searchTerm) ||
  //               job.category.toLowerCase().contains(searchTerm) ||
  //               (job.skills.toLowerCase().contains(searchTerm)) ||
  //               (job.qualifications.toLowerCase().contains(searchTerm)),
  //         )
  //         .toList(),
  //   );
  // }

  // // Get available categories without collectionGroup
  // Stream<List<String>> getAvailableCategories() {
  //   return getActiveJobs().map(
  //     (jobs) => jobs.map((job) => job.category).toSet().toList(),
  //   );
  // }

  // // Similar implementations for other getAvailable... methods
  // Stream<List<String>> getAvailableLocations() {
  //   return getActiveJobs().map(
  //     (jobs) => jobs.map((job) => job.location).toSet().toList(),
  //   );
  // }

  // Stream<List<String>> getAvailableCompanyNames() {
  //   return getActiveJobs().map(
  //     (jobs) => jobs.map((job) => job.companyName).toSet().toList(),
  //   );
  // }

  // Stream<List<String>> getAvailableDesignations() {
  //   return getActiveJobs().map(
  //     (jobs) => jobs.map((job) => job.designation).toSet().toList(),
  //   );
  // }

  // // Get job by ID (need to know which recruiter it belongs to)
  // Future<JobModel?> getJobById(String jobId, String recruiterEmail) async {
  //   try {
  //     final doc = await _firestore
  //         .collection('recruiters')
  //         .doc(recruiterEmail)
  //         .collection('jobs')
  //         .doc(jobId)
  //         .get();

  //     if (doc.exists) {
  //       return JobModel.fromMap(doc.id, doc.data()!);
  //     }
  //     return null;
  //   } catch (e) {
  //     throw Exception('Failed to get job: $e');
  //   }
  // }

  // // Apply for a job - creates application in both jobseeker and recruiter collections
  // Future<void> applyForJob({
  //   required String jobseekerEmail,
  //   required String jobseekerName,
  //   required String jobId,
  //   required String recruiterEmail,
  //   required String jobTitle,
  //   required String resumeUrl,
  //   required String coverLetter,
  // }) async {
  //   try {
  //     final applicationData = {
  //       'jobseekerEmail': jobseekerEmail,
  //       'jobseekerName': jobseekerName,
  //       'resumeUrl': resumeUrl,
  //       'coverLetter': coverLetter,
  //       'appliedAt': FieldValue.serverTimestamp(),
  //       'status': 'pending', // pending, reviewed, accepted, rejected
  //       'recruiterEmail': recruiterEmail, // Add this
  //       'jobId': jobId, // Add this
  //       'jobTitle': jobTitle, // Add this
  //     };

  //     final jobseekerApplicationData = {
  //       'job_id': jobId,
  //       'recruiter_email': recruiterEmail,
  //       'job_title': jobTitle,
  //       'applied_at': FieldValue.serverTimestamp(),
  //       'status': 'pending',
  //     };

  //     // Create application in jobseeker's applications subcollection
  //     await _firestore
  //         .collection('jobseekers')
  //         .doc(jobseekerEmail)
  //         .collection('applications')
  //         .add(jobseekerApplicationData);

  //     // Create application in recruiter's job applications subcollection
  //     await _firestore
  //         .collection('recruiters')
  //         .doc(recruiterEmail)
  //         .collection('jobs')
  //         .doc(jobId)
  //         .collection('applications')
  //         .add(applicationData);
  //   } catch (e) {
  //     throw Exception('Failed to apply for job: $e');
  //   }
  // }

  // // Get jobseeker's applications
  // Stream<List<Map<String, dynamic>>> getJobseekerApplications(
  //   String jobseekerEmail,
  // ) {
  //   return _firestore
  //       .collection('jobseekers')
  //       .doc(jobseekerEmail)
  //       .collection('applications')
  //       .orderBy('applied_at', descending: true)
  //       .snapshots()
  //       .map(
  //         (snapshot) => snapshot.docs
  //             .map((doc) => {'application_id': doc.id, ...doc.data()})
  //             .toList(),
  //       );
  // }

  // // Check if jobseeker has already applied for a job
  // Future<bool> hasAppliedForJob(
  //   String jobseekerEmail,
  //   String jobId,
  //   String recruiterEmail,
  // ) async {
  //   try {
  //     final query = await _firestore
  //         .collection('jobseekers')
  //         .doc(jobseekerEmail)
  //         .collection('applications')
  //         .where('job_id', isEqualTo: jobId)
  //         .where('recruiter_email', isEqualTo: recruiterEmail)
  //         .get();

  //     return query.docs.isNotEmpty;
  //   } catch (e) {
  //     throw Exception('Failed to check application status: $e');
  //   }
  // }

  // Add to JobRepository class
  // Stream<List<JobApplication>> getJobseekerApplicationsByEmail(
  //   String jobseekerEmail,
  // ) {
  //   return FirebaseFirestore.instance
  //       .collection('job_applications')
  //       .where('jobseekerEmail', isEqualTo: jobseekerEmail)
  //       .snapshots()
  //       .map((snapshot) {
  //         return snapshot.docs
  //             .map(
  //               (doc) => JobApplication.fromMap({
  //                 ...doc.data(),
  //                 'applicationId': doc.id,
  //               }),
  //             )
  //             .toList();
  //       });
  // }

  // Future<JobseekerApplicationStats> getJobseekerStats(
  //   String jobseekerEmail,
  // ) async {
  //   final applications = await getJobseekerApplicationsByEmail(
  //     jobseekerEmail,
  //   ).first;

  //   final total = applications.length;
  //   final pending = applications.where((app) => app.status == 'pending').length;
  //   final shortlisted = applications
  //       .where((app) => app.status == 'shortlisted')
  //       .length;
  //   final rejected = applications
  //       .where((app) => app.status == 'rejected')
  //       .length;
  //   final accepted = applications
  //       .where((app) => app.status == 'accepted')
  //       .length;

  //   return JobseekerApplicationStats(
  //     totalApplications: total,
  //     pending: pending,
  //     shortlisted: shortlisted,
  //     rejected: rejected,
  //     accepted: accepted,
  //   );
  // }

  // Future<JobModel?> getJobDetails(String jobId, String recruiterEmail) async {
  //   try {
  //     final doc = await FirebaseFirestore.instance
  //         .collection('recruiters')
  //         .doc(recruiterEmail)
  //         .collection('jobs')
  //         .doc(jobId)
  //         .get();

  //     if (doc.exists) {
  //       return JobModel.fromMap(doc.id, doc.data()!);
  //     }
  //     return null;
  //   } catch (e) {
  //     log('Error fetching job details: $e');
  //     return null;
  //   }
  // }

  //issue or report
  // Add to JobRepository class
  // Future<void> submitIssueReport({
  //   required String jobseekerEmail,
  //   required String jobseekerName,
  //   required String type, // 'issue' or 'report'
  //   required String title,
  //   required String description,
  // }) async {
  //   try {
  //     final issueData = {
  //       'jobseekerEmail': jobseekerEmail,
  //       'jobseekerName': jobseekerName,
  //       'type': type,
  //       'title': title,
  //       'description': description,
  //       'status': 'pending',
  //       'createdAt': FieldValue.serverTimestamp(),
  //       'updatedAt': FieldValue.serverTimestamp(),
  //     };

  //     // Store only in jobseeker's issues subcollection
  //     await _firestore
  //         .collection('jobseekers')
  //         .doc(jobseekerEmail)
  //         .collection('issues_reports')
  //         .add(issueData);
  //   } catch (e) {
  //     throw Exception('Failed to submit $type: $e');
  //   }
  // }

  // // Recruiter issue/report methods
  // Future<void> submitRecruiterIssueReport({
  //   required String recruiterEmail,
  //   required String recruiterName,
  //   required String type, // 'issue' or 'report'
  //   required String title,
  //   required String description,
  // }) async {
  //   try {
  //     final issueData = {
  //       'recruiterEmail': recruiterEmail,
  //       'recruiterName': recruiterName,
  //       'type': type,
  //       'title': title,
  //       'description': description,
  //       'status': 'pending',
  //       'createdAt': FieldValue.serverTimestamp(),
  //       'updatedAt': FieldValue.serverTimestamp(),
  //     };

  //     // Store in recruiter's issues subcollection
  //     await _firestore
  //         .collection('recruiters')
  //         .doc(recruiterEmail)
  //         .collection('issues_reports')
  //         .add(issueData);
  //   } catch (e) {
  //     throw Exception('Failed to submit $type: $e');
  //   }
  // }

  // // Get jobseeker's issues/reports
  // Stream<List<IssueReport>> getJobseekerIssues(String jobseekerEmail) {
  //   return _firestore
  //       .collection('jobseekers')
  //       .doc(jobseekerEmail)
  //       .collection('issues_reports')
  //       .orderBy('createdAt', descending: true)
  //       .snapshots()
  //       .map((snapshot) {
  //         return snapshot.docs
  //             .map((doc) => IssueReport.fromMap(doc.id, doc.data()))
  //             .toList();
  //       });
  // }

  // // Get recruiter's issues/reports
  // Stream<List<IssueReport>> getRecruiterIssues(String recruiterEmail) {
  //   return _firestore
  //       .collection('recruiters')
  //       .doc(recruiterEmail)
  //       .collection('issues_reports')
  //       .orderBy('createdAt', descending: true)
  //       .snapshots()
  //       .map((snapshot) {
  //         return snapshot.docs
  //             .map((doc) => IssueReport.fromMap(doc.id, doc.data()))
  //             .toList();
  //       });
  // }

  // // Provider for JobRepository

  // // Get all issues/reports for admin - fetch from both jobseekers and recruiters subcollections
  // Stream<List<AdminIssuereport>> getAllIssuesReports() {
  //   return _firestore.collection('jobseekers').snapshots().asyncMap((
  //     jobseekersSnapshot,
  //   ) async {
  //     final allIssues = <AdminIssuereport>[];

  //     // Fetch jobseeker issues
  //     for (final jobseekerDoc in jobseekersSnapshot.docs) {
  //       try {
  //         final issuesSnapshot = await _firestore
  //             .collection('jobseekers')
  //             .doc(jobseekerDoc.id)
  //             .collection('issues_reports')
  //             .orderBy('createdAt', descending: true)
  //             .get();

  //         allIssues.addAll(
  //           issuesSnapshot.docs
  //               .map((doc) => AdminIssuereport.fromMap(doc.id, doc.data()))
  //               .toList(),
  //         );
  //       } catch (e) {
  //         log('Error fetching issues for jobseeker ${jobseekerDoc.id}: $e');
  //       }
  //     }

  //     // Fetch recruiter issues
  //     final recruitersSnapshot = await _firestore
  //         .collection('recruiters')
  //         .get();
  //     for (final recruiterDoc in recruitersSnapshot.docs) {
  //       try {
  //         final issuesSnapshot = await _firestore
  //             .collection('recruiters')
  //             .doc(recruiterDoc.id)
  //             .collection('issues_reports')
  //             .orderBy('createdAt', descending: true)
  //             .get();

  //         allIssues.addAll(
  //           issuesSnapshot.docs
  //               .map((doc) => AdminIssuereport.fromMap(doc.id, doc.data()))
  //               .toList(),
  //         );
  //       } catch (e) {
  //         log('Error fetching issues for recruiter ${recruiterDoc.id}: $e');
  //       }
  //     }

  //     // Sort all issues by createdAt descending
  //     allIssues.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  //     return allIssues;
  //   });
  // }

  // // Update issue/report status (for admin) - supports both jobseeker and recruiter
  // Future<void> updateIssueStatus({
  //   required String issueId,
  //   required String status,
  //   required String userEmail, // Can be jobseekerEmail or recruiterEmail
  //   required String userType, // 'jobseeker' or 'recruiter'
  //   String? adminResponse,
  // }) async {
  //   try {
  //     final updateData = {
  //       'status': status,
  //       'updatedAt': FieldValue.serverTimestamp(),
  //       if (adminResponse != null) 'adminResponse': adminResponse,
  //     };

  //     final collection = userType == 'recruiter' ? 'recruiters' : 'jobseekers';

  //     // Update in the appropriate collection
  //     await _firestore
  //         .collection(collection)
  //         .doc(userEmail)
  //         .collection('issues_reports')
  //         .doc(issueId)
  //         .update(updateData);
  //   } catch (e) {
  //     throw Exception('Failed to update issue status: $e');
  //   }
  // }
}
