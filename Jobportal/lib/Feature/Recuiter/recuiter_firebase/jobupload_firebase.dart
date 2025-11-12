// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'dart:io';
// import 'package:jobapp/Feature/combomodel/jobupload_model.dart';

// class FirebaseService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseStorage _storage = FirebaseStorage.instance;

//   Future<String> uploadImage(File imageFile, String recruiterEmail) async {
//     try {
//       if (!await imageFile.exists()) {
//         throw Exception('Image file does not exist or is inaccessible');
//       }

//       final fileLength = await imageFile.length();
//       if (fileLength > 10 * 1024 * 1024) {
//         throw Exception('Image file is too large. Maximum size is 10MB');
//       }

//       String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
//       Reference storageRef = _storage.ref().child('company_images/$recruiterEmail/$fileName');
      
//       final metadata = SettableMetadata(
//         contentType: 'image/jpeg',
//         customMetadata: {'picked-file-path': imageFile.path},
//       );

//       UploadTask uploadTask = storageRef.putFile(imageFile, metadata);
//       TaskSnapshot snapshot = await uploadTask;
//       String downloadUrl = await snapshot.ref.getDownloadURL();
//       return downloadUrl;
//     } catch (e) {
//       throw Exception('Image upload failed: $e');
//     }
//   }

//   Future<void> saveJobData(JobModel jobData, String recruiterEmail) async {
//     try {
//       // Save under jobs collection with auto-generated document ID
//       await _firestore
//           .collection('jobs')
//           .add({
//             ...jobData.toMap(),
//             'recruiterEmail': recruiterEmail, 
//             'createdAt': FieldValue.serverTimestamp(),
//           });
//     } catch (e) {
//       throw Exception('Failed to save job data: $e');
//     }
//   }

//   // Get all jobs for a specific recruiter
//   Stream<List<JobModel>> getAllJobs(String recruiterEmail) {
//     return _firestore
//         .collection('jobs')
//         .where('recruiterEmail', isEqualTo: recruiterEmail)
//         // .orderBy('createdAt', descending: true)
//         .snapshots()
//         .map((snapshot) => snapshot.docs
//             .map((doc) => JobModel.fromMap(doc.id, doc.data()))
//             .toList());
//   }

//   // Get jobs by category for a specific recruiter
//   Stream<List<JobModel>> getJobsByCategory(String category, String recruiterEmail) {
//     return _firestore
//         .collection('jobs')
//         .where('recruiterEmail', isEqualTo: recruiterEmail)
//         .where('category', isEqualTo: category)
//         // .orderBy('createdAt', descending: true)
//         .snapshots()
//         .map((snapshot) => snapshot.docs
//             .map((doc) => JobModel.fromMap(doc.id, doc.data()))
//             .toList());
//   }

//   // Get active jobs for a specific recruiter
//   Stream<List<JobModel>> getActiveJobs(String recruiterEmail) {
//     return _firestore
//         .collection('jobs')
//         .where('recruiterEmail', isEqualTo: recruiterEmail)
//         .where('isActive', isEqualTo: true)
//         // .orderBy('createdAt', descending: true)
//         .snapshots()
//         .map((snapshot) => snapshot.docs
//             .map((doc) => JobModel.fromMap(doc.id, doc.data()))
//             .toList());
//   }

//   // Get inactive jobs for a specific recruiter
//   Stream<List<JobModel>> getInactiveJobs(String recruiterEmail) {
//     return _firestore
//         .collection('jobs')
//         .where('recruiterEmail', isEqualTo: recruiterEmail)
//         .where('isActive', isEqualTo: false)
//         // .orderBy('createdAt', descending: true)
//         .snapshots()
//         .map((snapshot) => snapshot.docs
//             .map((doc) => JobModel.fromMap(doc.id, doc.data()))
//             .toList());
//   }

//   // Get total jobs count for a specific recruiter
//   Stream<int> getTotalJobsCount(String recruiterEmail) {
//     return _firestore
//         .collection('jobs')
//         .where('recruiterEmail', isEqualTo: recruiterEmail)
//         .snapshots()
//         .map((snapshot) => snapshot.docs.length);
//   }

//   // Get active jobs count for a specific recruiter
//   Stream<int> getActiveJobsCount(String recruiterEmail) {
//     return _firestore
//         .collection('jobs')
//         .where('recruiterEmail', isEqualTo: recruiterEmail)
//         .where('isActive', isEqualTo: true)
//         .snapshots()
//         .map((snapshot) => snapshot.docs.length);
//   }

//   // Get inactive jobs count for a specific recruiter
//   Stream<int> getInactiveJobsCount(String recruiterEmail) {
//     return _firestore
//         .collection('jobs')
//         .where('recruiterEmail', isEqualTo: recruiterEmail)
//         .where('isActive', isEqualTo: false)
//         .snapshots()
//         .map((snapshot) => snapshot.docs.length);
//   }

//   // Toggle job status for a specific recruiter
//   Future<void> updateJobStatus(String jobId, bool isActive, String recruiterEmail) async {
//     try {
//       await _firestore
//           .collection('jobs')
//           .doc(jobId)
//           .update({
//         'isActive': isActive,
//         'updatedAt': FieldValue.serverTimestamp(),
//       });
//     } catch (e) {
//       throw Exception('Failed to update job status: $e');
//     }
//   }

//   // Get job by ID for a specific recruiter
//   Future<JobModel?> getJobById(String jobId, String recruiterEmail) async {
//     try {
//       final doc = await _firestore
//           .collection('jobs')
//           .doc(jobId)
//           .get();
      
//       if (doc.exists && doc.data()?['recruiterEmail'] == recruiterEmail) {
//         return JobModel.fromMap(doc.id, doc.data()!);
//       }
//       return null;
//     } catch (e) {
//       throw Exception('Failed to get job: $e');
//     }
//   }

//   // Update job data for a specific recruiter
//   Future<void> updateJobData(JobModel jobData, String recruiterEmail) async {
//   try {
//     await _firestore
//         .collection('jobs')
//         .doc(jobData.id)
//         .update({
//       'companyName': jobData.companyName,
//       'designation': jobData.designation,
//       'ctc': jobData.ctc,
//       'noticePeriod': jobData.noticePeriod,
//       'location': jobData.location,
//       'application': jobData.application,
//       'imageUrl': jobData.imageUrl,
//       'category': jobData.category,
//       'isActive': jobData.isActive,
//       'benefits': jobData.benefits,
//       'qualifications': jobData.qualifications,
//       'skills': jobData.skills,
//       'requirements': jobData.requirements,
//       'experience': jobData.experience,
//       'ageRange': jobData.ageRange,
//       'isUrgentHiring': jobData.isUrgentHiring,
//       'updatedAt': FieldValue.serverTimestamp(),
//     });
//   } catch (e) {
//     throw Exception('Failed to update job data: $e');
//   }
// }
//   // Delete job for a specific recruiter
//   Future<void> deleteJob(String jobId, String recruiterEmail) async {
//     try {
//       await _firestore
//           .collection('jobs')
//           .doc(jobId)
//           .delete();
//     } catch (e) {
//       throw Exception('Failed to delete job: $e');
//     }
//   }

//   // Get all recruiters (for admin purposes) - Now we need to query distinct emails
//   Stream<List<String>> getAllRecruiters() {
//     return _firestore
//         .collection('jobs')
//         .snapshots()
//         .map((snapshot) {
//           final emails = <String>{};
//           for (final doc in snapshot.docs) {
//             final email = doc.data()['recruiterEmail'];
//             if (email != null) {
//               emails.add(email);
//             }
//           }
//           return emails.toList();
//         });
//   }

//   Stream<List<JobModel>> getRecentJobs(String recruiterEmail, {int limit = 3}) {
//     return _firestore
//         .collection('jobs')
//         .where('recruiterEmail', isEqualTo: recruiterEmail)
//         // .orderBy('createdAt', descending: true)
//         .limit(limit)
//         .snapshots()
//         .map((snapshot) => snapshot.docs
//             .map((doc) => JobModel.fromMap(doc.id, doc.data()))
//             .toList());
//   }

//   // Get recent jobs with time difference calculation
//   Stream<List<Map<String, dynamic>>> getRecentJobsWithTime(String recruiterEmail, {int limit = 3}) {
//     return _firestore
//         .collection('jobs')
//         .where('recruiterEmail', isEqualTo: recruiterEmail)
//         // .orderBy('createdAt', descending: true)
//         .limit(limit)
//         .snapshots()
//         .map((snapshot) {
//       return snapshot.docs.map((doc) {
//         final job = JobModel.fromMap(doc.id, doc.data());
//         final timeDifference = _calculateTimeDifference(job.createdAt);
//         return {
//           'job': job,
//           'timeAgo': timeDifference,
//           'isNew': _isNewJob(job.createdAt),
//         };
//       }).toList();
//     });
//   }
 
//  Future<void> updateUrgentHiringStatus(String jobId, bool isUrgentHiring, String recruiterEmail) async {
//   try {
//     await _firestore
//         .collection('jobs')
//         .doc(jobId)
//         .update({
//       'isUrgentHiring': isUrgentHiring,
//       'updatedAt': FieldValue.serverTimestamp(),
//     });
//   } catch (e) {
//     throw Exception('Failed to update urgent hiring status: $e');
//   }
// }
//   // Calculate time difference in human readable format
//   String _calculateTimeDifference(DateTime jobTime) {
//     final now = DateTime.now();
//     final difference = now.difference(jobTime);

//     if (difference.inMinutes < 1) {
//       return 'Just now';
//     } else if (difference.inMinutes < 60) {
//       return '${difference.inMinutes} min ago';
//     } else if (difference.inHours < 24) {
//       return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
//     } else if (difference.inDays < 7) {
//       return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
//     } else if (difference.inDays < 30) {
//       final weeks = (difference.inDays / 7).floor();
//       return '$weeks week${weeks > 1 ? 's' : ''} ago';
//     } else {
//       final months = (difference.inDays / 30).floor();
//       return '$months month${months > 1 ? 's' : ''} ago';
//     }
//   }

//   // Check if job is new (less than 24 hours old)
//   bool _isNewJob(DateTime jobTime) {
//     final now = DateTime.now();
//     return now.difference(jobTime).inHours < 24;
//   }
// }


// All in one file

import 'dart:developer';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jobapp/Feature/combomodel/application_model.dart';
import 'dart:io';
import 'package:jobapp/Feature/combomodel/jobupload_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadImage(File imageFile, String recruiterEmail) async {
    try {
      if (!await imageFile.exists()) {
        throw Exception('Image file does not exist or is inaccessible');
      }

      final fileLength = await imageFile.length();
      if (fileLength > 10 * 1024 * 1024) {
        throw Exception('Image file is too large. Maximum size is 10MB');
      }

      String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference storageRef = _storage.ref().child('company_images/$recruiterEmail/$fileName');
      
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'picked-file-path': imageFile.path},
      );

      UploadTask uploadTask = storageRef.putFile(imageFile, metadata);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Image upload failed: $e');
    }
  }

  Future<void> saveJobData(JobModel jobData, String recruiterEmail) async {
  try {
    // Save to nested structure (for recruiters)
    final docRef = await _firestore
        .collection('recruiters')
        .doc(recruiterEmail)
        .collection('jobs')
        .add({
          ...jobData.toMap(),
          'recruiterEmail': recruiterEmail,
          'createdAt': FieldValue.serverTimestamp(),
        });

    // Also save to flat collection (for jobseekers to browse)
    await _firestore
        .collection('jobs')
        .doc(docRef.id)
        .set({
          ...jobData.toMap(),
          'recruiterEmail': recruiterEmail,
          'jobId': docRef.id, // Store the same ID
          'createdAt': FieldValue.serverTimestamp(),
        });
  } catch (e) {
    throw Exception('Failed to save job data: $e');
  }
}
  // Get all jobs for a specific recruiter
  Stream<List<JobModel>> getAllJobs(String recruiterEmail) {
    return _firestore
        .collection('recruiters')
        .doc(recruiterEmail)
        .collection('jobs')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => JobModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  // Get jobs by category for a specific recruiter
  Stream<List<JobModel>> getJobsByCategory(String category, String recruiterEmail) {
    return _firestore
        .collection('recruiters')
        .doc(recruiterEmail)
        .collection('jobs')
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => JobModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  // Get active jobs for a specific recruiter
  Stream<List<JobModel>> getActiveJobs(String recruiterEmail) {
    return _firestore
        .collection('recruiters')
        .doc(recruiterEmail)
        .collection('jobs')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => JobModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  // Get inactive jobs for a specific recruiter
  Stream<List<JobModel>> getInactiveJobs(String recruiterEmail) {
    return _firestore
        .collection('recruiters')
        .doc(recruiterEmail)
        .collection('jobs')
        .where('isActive', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => JobModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  // Get total jobs count for a specific recruiter
  Stream<int> getTotalJobsCount(String recruiterEmail) {
    return _firestore
        .collection('recruiters')
        .doc(recruiterEmail)
        .collection('jobs')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Get active jobs count for a specific recruiter
  Stream<int> getActiveJobsCount(String recruiterEmail) {
    return _firestore
        .collection('recruiters')
        .doc(recruiterEmail)
        .collection('jobs')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Get inactive jobs count for a specific recruiter
  Stream<int> getInactiveJobsCount(String recruiterEmail) {
    return _firestore
        .collection('recruiters')
        .doc(recruiterEmail)
        .collection('jobs')
        .where('isActive', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Toggle job status for a specific recruiter
  Future<void> updateJobStatus(String jobId, bool isActive, String recruiterEmail) async {
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
      throw Exception('Failed to update job status: $e');
    }
  }

  // Get job by ID for a specific recruiter
  Future<JobModel?> getJobById(String jobId, String recruiterEmail) async {
    try {
      final doc = await _firestore
          .collection('recruiters')
          .doc(recruiterEmail)
          .collection('jobs')
          .doc(jobId)
          .get();
      
      if (doc.exists) {
        return JobModel.fromMap(doc.id, doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get job: $e');
    }
  }

  // Update job data for a specific recruiter
  Future<void> updateJobData(JobModel jobData, String recruiterEmail) async {
    try {
      await _firestore
          .collection('recruiters')
          .doc(recruiterEmail)
          .collection('jobs')
          .doc(jobData.id)
          .update({
        'companyName': jobData.companyName,
        'designation': jobData.designation,
        'ctc': jobData.ctc,
        'noticePeriod': jobData.noticePeriod,
        'location': jobData.location,
        'application': jobData.application,
        'imageUrl': jobData.imageUrl,
        'category': jobData.category,
        'isActive': jobData.isActive,
        'benefits': jobData.benefits,
        'qualifications': jobData.qualifications,
        'skills': jobData.skills,
        'requirements': jobData.requirements,
        'experience': jobData.experience,
        'ageRange': jobData.ageRange,
        'isUrgentHiring': jobData.isUrgentHiring,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update job data: $e');
    }
  }

  // Delete job for a specific recruiter
  Future<void> deleteJob(String jobId, String recruiterEmail) async {
    try {
      await _firestore
          .collection('recruiters')
          .doc(recruiterEmail)
          .collection('jobs')
          .doc(jobId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete job: $e');
    }
  }

  // Get all recruiters (for admin purposes)
  Stream<List<String>> getAllRecruiters() {
    return _firestore
        .collection('recruiters')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => doc.id)
            .toList());
  }

  Stream<List<JobModel>> getRecentJobs(String recruiterEmail, {int limit = 3}) {
    return _firestore
        .collection('recruiters')
        .doc(recruiterEmail)
        .collection('jobs')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => JobModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  // Get recent jobs with time difference calculation
  Stream<List<Map<String, dynamic>>> getRecentJobsWithTime(String recruiterEmail, {int limit = 3}) {
    return _firestore
        .collection('recruiters')
        .doc(recruiterEmail)
        .collection('jobs')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final job = JobModel.fromMap(doc.id, doc.data());
        final timeDifference = _calculateTimeDifference(job.createdAt);
        return {
          'job': job,
          'timeAgo': timeDifference,
          'isNew': _isNewJob(job.createdAt),
        };
      }).toList();
    });
  }

  Future<void> updateUrgentHiringStatus(String jobId, bool isUrgentHiring, String recruiterEmail) async {
    try {
      await _firestore
          .collection('recruiters')
          .doc(recruiterEmail)
          .collection('jobs')
          .doc(jobId)
          .update({
        'isUrgentHiring': isUrgentHiring,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update urgent hiring status: $e');
    }
  }

  // Calculate time difference in human readable format
  String _calculateTimeDifference(DateTime jobTime) {
    final now = DateTime.now();
    final difference = now.difference(jobTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks week${weeks > 1 ? 's' : ''} ago';
    } else {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    }
  }

  // Check if job is new (less than 24 hours old)
  bool _isNewJob(DateTime jobTime) {
    final now = DateTime.now();
    return now.difference(jobTime).inHours < 24;
  }
  // Get applications for a specific job
Stream<List<ApplicationModel>> getApplicationsForJob(String recruiterEmail, String jobId) {
   log('=== FIRESTORE QUERY DEBUG ===');
  log('Querying applications for:');
  log('Recruiter Email: $recruiterEmail');
  log('Job ID: $jobId');
  log('Full path: recruiters/$recruiterEmail/jobs/$jobId/applications');
  return _firestore
      .collection('recruiters')
      .doc(recruiterEmail)
      .collection('jobs')
      .doc(jobId)
      .collection('applications')
      .orderBy('appliedAt', descending: true)
      .snapshots()
      .map((snapshot) {
        log('Found ${snapshot.docs.length} applications for job $jobId');
        return snapshot.docs
            .map((doc) {
              log('Application doc: ${doc.id} - ${doc.data()}');
              return ApplicationModel.fromMap(doc.id, doc.data());
            })
            .toList();
      });
}

  // New method to get application count for a job
  Stream<int> getApplicationCount(String recruiterEmail, String jobId) {
    return _firestore
        .collection('recruiters')
        .doc(recruiterEmail)
        .collection('jobs')
        .doc(jobId)
        .collection('applications')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
// Get all applications for recruiter (across all jobs)
// Alternative method without collectionGroup query
Stream<List<ApplicationModel>> getAllApplicationsForRecruiter(String recruiterEmail) {
  log('=== FIRESTORE QUERY DEBUG (ALL APPLICATIONS) ===');
  log('Querying ALL applications for recruiter: $recruiterEmail');
  
  return _firestore
      .collection('recruiters')
      .doc(recruiterEmail)
      .collection('jobs')
      .snapshots()
      .asyncMap((jobsSnapshot) async {
        log('Found ${jobsSnapshot.docs.length} jobs for recruiter $recruiterEmail');
        
        final allApplications = <ApplicationModel>[];
        for (final jobDoc in jobsSnapshot.docs) {
          try {
            log('Checking job: ${jobDoc.id} - ${jobDoc.data()}');
            
            final applicationsSnapshot = await _firestore
                .collection('recruiters')
                .doc(recruiterEmail)
                .collection('jobs')
                .doc(jobDoc.id)
                .collection('applications')
                .orderBy('appliedAt', descending: true)
                .get();
            
            log('Found ${applicationsSnapshot.docs.length} applications for job ${jobDoc.id}');
            
            allApplications.addAll(applicationsSnapshot.docs
                .map((doc) {
                  log('Application: ${doc.id} - ${doc.data()}');
                  return ApplicationModel.fromMap(doc.id, doc.data());
                })
                .toList());
          } catch (e) {
            log('Error fetching applications for job ${jobDoc.id}: $e');
          }
        }
        
        // Sort all applications by appliedAt date
        allApplications.sort((a, b) => b.appliedAt.compareTo(a.appliedAt));
        log('Total applications found: ${allApplications.length}');
        return allApplications;
      });
}

// Update application status
Future<void> updateApplicationStatus({
  required String recruiterEmail,
  required String jobId,
  required String applicationId,
  required String newStatus,
}) async {
  try {
    await _firestore
        .collection('recruiters')
        .doc(recruiterEmail)
        .collection('jobs')
        .doc(jobId)
        .collection('applications')
        .doc(applicationId)
        .update({
          'status': newStatus,
          'updatedAt': FieldValue.serverTimestamp(),
        });

    // Also update in jobseeker's applications collection
    final applicationDoc = await _firestore
        .collection('recruiters')
        .doc(recruiterEmail)
        .collection('jobs')
        .doc(jobId)
        .collection('applications')
        .doc(applicationId)
        .get();

    if (applicationDoc.exists) {
      final applicationData = applicationDoc.data()!;
      final jobseekerEmail = applicationData['jobseekerEmail'];
      
      // Find and update in jobseeker's applications
      final jobseekerApplications = await _firestore
          .collection('jobseekers')
          .doc(jobseekerEmail)
          .collection('applications')
          .where('job_id', isEqualTo: jobId)
          .where('recruiter_email', isEqualTo: recruiterEmail)
          .get();

      for (final doc in jobseekerApplications.docs) {
        await doc.reference.update({
          'status': newStatus,
          'updated_at': FieldValue.serverTimestamp(),
        });
      }
    }
  } catch (e) {
    throw Exception('Failed to update application status: $e');
  }
}

// Get application statistics
Future<Map<String, int>> getApplicationStats(String recruiterEmail, String jobId) async {
  try {
    final applications = await _firestore
        .collection('recruiters')
        .doc(recruiterEmail)
        .collection('jobs')
        .doc(jobId)
        .collection('applications')
        .get();

    final stats = {
      'total': applications.docs.length,
      'pending': applications.docs.where((doc) => doc.data()['status'] == 'pending').length,
      'shortlisted': applications.docs.where((doc) => doc.data()['status'] == 'shortlisted').length,
      'rejected': applications.docs.where((doc) => doc.data()['status'] == 'rejected').length,
    };

    return stats;
  } catch (e) {
    throw Exception('Failed to get application stats: $e');
  }
}
// Delete application from both recruiter and jobseeker collections
Future<void> deleteApplication({
  required String recruiterEmail,
  required String jobId,
  required String applicationId,
}) async {
  try {
    log('=== DELETING APPLICATION ===');
    log('Recruiter Email: $recruiterEmail');
    log('Job ID: $jobId');
    log('Application ID: $applicationId');

    // First, get the application data to find jobseeker email
    final applicationDoc = await _firestore
        .collection('recruiters')
        .doc(recruiterEmail)
        .collection('jobs')
        .doc(jobId)
        .collection('applications')
        .doc(applicationId)
        .get();

    if (!applicationDoc.exists) {
      throw Exception('Application not found');
    }

    final applicationData = applicationDoc.data()!;
    final jobseekerEmail = applicationData['jobseekerEmail'] as String?;
    final jobTitle = applicationData['jobTitle'] as String?;

    log('Jobseeker Email: $jobseekerEmail');
    log('Job Title: $jobTitle');

    // Delete from recruiter's applications collection
    await _firestore
        .collection('recruiters')
        .doc(recruiterEmail)
        .collection('jobs')
        .doc(jobId)
        .collection('applications')
        .doc(applicationId)
        .delete();

    log('✅ Application deleted from recruiter collection');

    // Also delete from jobseeker's applications collection if jobseekerEmail exists
    if (jobseekerEmail != null && jobseekerEmail.isNotEmpty) {
      try {
        // Find the application in jobseeker's collection
        final jobseekerApplications = await _firestore
            .collection('jobseekers')
            .doc(jobseekerEmail)
            .collection('applications')
            .where('job_id', isEqualTo: jobId)
            .where('recruiter_email', isEqualTo: recruiterEmail)
            .get();

        for (final doc in jobseekerApplications.docs) {
          await doc.reference.delete();
          log('✅ Application deleted from jobseeker collection: ${doc.id}');
        }
      } catch (e) {
        log('⚠️ Could not delete from jobseeker collection: $e');
        // Continue even if jobseeker deletion fails
      }
    }

    log('🎯 Application deletion completed successfully');
  } catch (e) {
    log('❌ Failed to delete application: $e');
    throw Exception('Failed to delete application: $e');
  }
}
}