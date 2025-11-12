// lib/Feature/AdminSide/provider/admin_jobseeker_providers.dart
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:jobapp/Feature/AdminSide/model/application_model.dart';
import 'package:jobapp/Feature/JobSeeker/modelclass/jobseeker_info.dart';
import 'package:jobapp/Feature/JobSeeker/provider/jobaccess_provider.dart';
import 'package:jobapp/Feature/JobSeeker/provider/jobseeker_provider.dart';
// All jobseekers list
final allJobSeekersProvider = StreamProvider<List<JobseekerModel>>((ref) {
  final jobseekerService = ref.watch(jobseekerFirebaseServiceProvider);
  return jobseekerService.getAllJobSeekers();
});

// Selected jobseeker provider
final selectedJobseekerProvider = StateProvider<JobseekerModel?>((ref) => null);

// Jobseeker applications provider
final jobseekerApplicationsProvider = StreamProvider.family<List<JobApplication>, String>((ref, jobseekerEmail) {
  final repository = ref.read(jobRepositoryProvider);
  return repository.getJobseekerApplicationsByEmail(jobseekerEmail);
});

// Jobseeker stats provider
final jobseekerStatsProvider = FutureProvider.family<JobseekerApplicationStats, String>((ref, jobseekerEmail) async {
  final repository = ref.read(jobRepositoryProvider);
  return await repository.getJobseekerStats(jobseekerEmail);
});

// Detailed jobseeker info provider
final detailedJobseekerInfoProvider = FutureProvider.family<JobseekerDetailedInfo?, String>((ref, jobseekerEmail) async {
  try {
    final jobseekerService = ref.read(jobseekerFirebaseServiceProvider);
    final repository = ref.read(jobRepositoryProvider);
    
    // Get jobseeker basic info
    final jobseeker = await jobseekerService.getJobseekerInfo(jobseekerEmail);
    if (jobseeker == null) return null;
    
    // Get applications
    final applications = await repository.getJobseekerApplicationsByEmail(jobseekerEmail).first;
    
    // Get stats
    final stats = await repository.getJobseekerStats(jobseekerEmail);
    
    return JobseekerDetailedInfo(
      jobseeker: jobseeker,
      stats: stats,
      applications: applications,
    );
  } catch (e) {
    log('Error fetching detailed jobseeker info: $e');
    return null;
  }
});