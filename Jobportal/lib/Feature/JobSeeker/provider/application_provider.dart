// application_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:jobapp/Feature/JobSeeker/firebase_crud/jobaccess_repository.dart';
import 'package:jobapp/Feature/JobSeeker/modelclass/jobseeker_info.dart';
import 'package:jobapp/Feature/JobSeeker/provider/jobseeker_provider.dart';
import 'package:jobapp/Feature/combomodel/jobupload_model.dart';

// Repository provider
final jobRepositoryProvider = Provider<JobRepository>((ref) => JobRepository());

// Applied Jobs Provider - Real-time stream of all applied jobs
final appliedJobsProvider =
    StreamProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
      final jobseekerState = ref.watch(jobseekerProvider);
      final jobseekerEmail = jobseekerState.jobseekerInfo?.email ?? '';

      if (jobseekerEmail.isEmpty) {
        return Stream.value([]);
      }

      final repository = ref.read(jobRepositoryProvider);
      return repository.getJobseekerApplications(jobseekerEmail);
    });
// Application Status Count Provider
final applicationStatsProvider = Provider.autoDispose<ApplicationStats>((ref) {
  final applicationsAsync = ref.watch(appliedJobsProvider);
  return applicationsAsync.when(
    data: (applications) {
      final total = applications.length;
      final pending = applications
          .where((app) => app['status'] == 'pending')
          .length;
      final shortlisted = applications
          .where((app) => app['status'] == 'shortlisted')
          .length;
      final rejected = applications
          .where((app) => app['status'] == 'rejected')
          .length;
      return ApplicationStats(
        total: total,
        pending: pending,
        shortlisted: shortlisted,
        rejected: rejected,
      );
    },
    loading: () => ApplicationStats.zero(),
    error: (error, stack) => ApplicationStats.zero(),
  );
});

// Individual count providers for easy access
final totalApplicationsProvider = Provider.autoDispose<int>((ref) {
  return ref.watch(applicationStatsProvider).total;
});

final pendingApplicationsProvider = Provider.autoDispose<int>((ref) {
  return ref.watch(applicationStatsProvider).pending;
});

final shortlistedApplicationsProvider = Provider.autoDispose<int>((ref) {
  return ref.watch(applicationStatsProvider).shortlisted;
});

final rejectedApplicationsProvider = Provider.autoDispose<int>((ref) {
  return ref.watch(applicationStatsProvider).rejected;
});

// Filtered applications by status
final filteredApplicationsProvider = Provider.autoDispose
    .family<List<Map<String, dynamic>>, String>((ref, status) {
      final applicationsAsync = ref.watch(appliedJobsProvider);

      return applicationsAsync.when(
        data: (applications) {
          if (status == 'all') return applications;
          return applications.where((app) => app['status'] == status).toList();
        },
        loading: () => [],
        error: (error, stack) => [],
      );
    });

// Application status update provider
final applicationUpdateProvider =
    StateNotifierProvider<ApplicationUpdateNotifier, bool>((ref) {
      return ApplicationUpdateNotifier(ref);
    });

class ApplicationUpdateNotifier extends StateNotifier<bool> {
  final Ref ref;
  ApplicationUpdateNotifier(this.ref) : super(false);

  Future<void> applyForJob({
    required JobModel job,
    required JobseekerModel jobseekerInfo,
    String coverLetter = '',
  }) async {
    state = true;
    try {
      final repository = ref.read(jobRepositoryProvider);
      await repository.applyForJob(
        jobseekerEmail: jobseekerInfo.email,
        jobseekerName: jobseekerInfo.name,
        jobId: job.id,
        recruiterEmail: job.recruiterEmail,
        jobTitle: job.designation,
        resumeUrl: jobseekerInfo.resumeUrl,
        coverLetter: coverLetter,
      );
      state = false;
    } catch (e) {
      state = false;
      rethrow;
    }
  }
}

// Stats model
class ApplicationStats {
  final int total;
  final int pending;
  final int shortlisted;
  final int rejected;

  ApplicationStats({
    required this.total,
    required this.pending,
    required this.shortlisted,
    required this.rejected,
  });

  factory ApplicationStats.zero() {
    return ApplicationStats(total: 0, pending: 0, shortlisted: 0, rejected: 0);
  }
}
