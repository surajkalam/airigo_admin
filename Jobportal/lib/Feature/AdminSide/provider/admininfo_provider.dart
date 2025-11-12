// providers/admin_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobapp/Feature/JobSeeker/modelclass/jobseeker_info.dart';
import 'package:jobapp/Feature/JobSeeker/provider/jobseeker_provider.dart';
import 'package:jobapp/Feature/Recuiter/provider/requiterinfo_provider.dart';

import '../../Recuiter/recuiter_model/recuiterinfo_model.dart';
// Provider to get all recruiters
final allRecruitersProvider = StreamProvider<List<RecruiterModel>>((ref) {
  final recruiterService = ref.watch(firebaseRecruiterServiceProvider);
  return recruiterService.getAllRecruiters();
});
// Provider to get all jobseekers
final allJobSeekersProvider = StreamProvider<List<JobseekerModel>>((ref) {
  final jobseekerService = ref.watch(jobseekerFirebaseServiceProvider);
  return jobseekerService.getAllJobSeekers();
});

// Admin stats provider
final adminStatsProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final recruitersAsync = ref.watch(allRecruitersProvider);
  final jobSeekersAsync = ref.watch(allJobSeekersProvider);

  // Create a stream that emits when either recruiters or jobseekers change
  return Stream.value(null).asyncMap((_) async {
    final recruiters = recruitersAsync.value ?? [];
    final jobSeekers = jobSeekersAsync.value ?? [];

    return {
      'totalRecruiters': recruiters.length,
      'totalJobSeekers': jobSeekers.length,
      'totalPayments': 0,
      'activeJobs': 0,
    };
  });
});