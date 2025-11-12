//job upload provider
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:jobapp/Authentication/user_provider.dart';

import 'package:jobapp/Feature/Recuiter/recuiter_firebase/jobupload_firebase.dart';

import 'package:jobapp/Feature/combomodel/jobupload_model.dart';

// Firebase Service Provider
final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService();
});

// Current User Email Provider (you already have this)

// Job State
class JobState {
  final bool isLoading;
  final String? error;
  final bool success;
  final bool isDeleting;

  const JobState({
    this.isLoading = false,
    this.error,
    this.success = false,
    this.isDeleting = false,
  });

  JobState copyWith({
    bool? isLoading,
    String? error,
    bool? success,
    bool? isDeleting,
  }) {
    return JobState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      success: success ?? this.success,
      isDeleting: isDeleting ?? this.isDeleting,
    );
  }
}

// Job Notifier
class JobNotifier extends StateNotifier<JobState> {
  final FirebaseService _firebaseService;
  final Ref _ref;

   JobNotifier(this._firebaseService, this._ref) : super(const JobState());

  String get _recruiterEmail => _ref.read(currentRecruiterUserEmailProvider);

  Future<String> uploadImage(File imageFile) async {
    try {
      return await _firebaseService.uploadImage(imageFile, _recruiterEmail);
    } catch (e) {
      state = state.copyWith(error: 'Image upload failed: $e');
      rethrow;
    }
  }

  Future<void> saveJob(JobModel jobData) async {
    state = state.copyWith(isLoading: true, error: null, success: false);
    try {
    // Create a new job with recruiterEmail
    final jobWithEmail = jobData.copyWith(recruiterEmail: _recruiterEmail);
    await _firebaseService.saveJobData(jobWithEmail, _recruiterEmail);
    state = state.copyWith(isLoading: false, success: true);
  } catch (e) {
    state = state.copyWith(isLoading: false, error: 'Failed to save job: $e');
    rethrow;
  }
  }
    Future<void> updateJob(JobModel jobData) async {
    state = state.copyWith(isLoading: true, error: null, success: false);
    try {
      // Update existing job with recruiterEmail
      final jobWithEmail = jobData.copyWith(recruiterEmail: _recruiterEmail);
      await _firebaseService.updateJobData(jobWithEmail, _recruiterEmail);
      state = state.copyWith(isLoading: false, success: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to update job: $e');
      rethrow;
    }
  }
   Future<void> deleteJob(String jobId) async {
    state = state.copyWith(isDeleting: true, error: null);
    try {
      await _firebaseService.deleteJob(jobId, _recruiterEmail);
      state = state.copyWith(isDeleting: false, success: true);
    } catch (e) {
      state = state.copyWith(isDeleting: false, error: 'Failed to delete job: $e');
      rethrow;
    }
  }

  Future<void> toggleJobStatus(String jobId, bool currentStatus) async {
    try {
      await _firebaseService.updateJobStatus(jobId, !currentStatus, _recruiterEmail);
    } catch (e) {
      state = state.copyWith(error: 'Failed to update job status: $e');
      rethrow;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void clearSuccess() {
    state = state.copyWith(success: false);
  }
}

// Job Notifier Provider
final jobNotifierProvider = StateNotifierProvider<JobNotifier, JobState>((ref) {
  final firebaseService = ref.read(firebaseServiceProvider);
  return JobNotifier(firebaseService, ref);
});
// delete operations
final jobDeleteProvider = FutureProvider.family<void, String>((ref, jobId) async {
  final jobNotifier = ref.read(jobNotifierProvider.notifier);
  await jobNotifier.deleteJob(jobId);
});

//  getting individual job details
final jobDetailProvider = StreamProvider.family<JobModel?, String>((ref, jobId) {
  final firebaseService = ref.read(firebaseServiceProvider);
  final recruiterEmail = ref.watch(currentRecruiterUserEmailProvider);
  if (recruiterEmail.isEmpty) return Stream.value(null);
   return Stream.fromFuture(firebaseService.getJobById(jobId, recruiterEmail));
});

// Stream providers with recruiter email
final airlineJobsProvider = StreamProvider<List<JobModel>>((ref) {
  final firebaseService = ref.read(firebaseServiceProvider);
  final recruiterEmail = ref.watch(currentRecruiterUserEmailProvider);
  if (recruiterEmail.isEmpty) return Stream.value([]);
  return firebaseService.getJobsByCategory('Airline', recruiterEmail);
});

final hospitalityJobsProvider = StreamProvider<List<JobModel>>((ref) {
  final firebaseService = ref.read(firebaseServiceProvider);
  final recruiterEmail = ref.watch(currentRecruiterUserEmailProvider);
  if (recruiterEmail.isEmpty) return Stream.value([]);
  return firebaseService.getJobsByCategory('Hospitality', recruiterEmail);
});

final allJobsProvider = StreamProvider<List<JobModel>>((ref) {
  final firebaseService = ref.read(firebaseServiceProvider);
  final recruiterEmail = ref.watch(currentRecruiterUserEmailProvider);
  if (recruiterEmail.isEmpty) return Stream.value([]);
  return firebaseService.getAllJobs(recruiterEmail);
});

final activeJobsProvider = StreamProvider<List<JobModel>>((ref) {
  final firebaseService = ref.read(firebaseServiceProvider);
  final recruiterEmail = ref.watch(currentRecruiterUserEmailProvider);
  if (recruiterEmail.isEmpty) return Stream.value([]);
  return firebaseService.getActiveJobs(recruiterEmail);
});

final inactiveJobsProvider = StreamProvider<List<JobModel>>((ref) {
  final firebaseService = ref.read(firebaseServiceProvider);
  final recruiterEmail = ref.watch(currentRecruiterUserEmailProvider);
  if (recruiterEmail.isEmpty) return Stream.value([]);
  return firebaseService.getInactiveJobs(recruiterEmail);
});

// Count providers
final totalJobsCountProvider = StreamProvider<int>((ref) {
  final firebaseService = ref.read(firebaseServiceProvider);
  final recruiterEmail = ref.watch(currentRecruiterUserEmailProvider);
  if (recruiterEmail.isEmpty) return Stream.value(0);
  return firebaseService.getTotalJobsCount(recruiterEmail);
});

final activeJobsCountProvider = StreamProvider<int>((ref) {
  final firebaseService = ref.read(firebaseServiceProvider);
  final recruiterEmail = ref.watch(currentRecruiterUserEmailProvider);
  if (recruiterEmail.isEmpty) return Stream.value(0);
  return firebaseService.getActiveJobsCount(recruiterEmail);
});

final inactiveJobsCountProvider = StreamProvider<int>((ref) {
  final firebaseService = ref.read(firebaseServiceProvider);
  final recruiterEmail = ref.watch(currentRecruiterUserEmailProvider);
  if (recruiterEmail.isEmpty) return Stream.value(0);
  return firebaseService.getInactiveJobsCount(recruiterEmail);
});

// Job status toggle provider
final jobStatusProvider = StateNotifierProvider.family<JobStatusNotifier, AsyncValue<bool>, String>((ref, jobId) {
  final firebaseService = ref.read(firebaseServiceProvider);
  return JobStatusNotifier(firebaseService, jobId, ref);
});

class JobStatusNotifier extends StateNotifier<AsyncValue<bool>> {
  final FirebaseService _firebaseService;
  final String jobId;
  final Ref _ref;

  JobStatusNotifier(this._firebaseService, this.jobId, this._ref) : super(const AsyncValue.loading()) {
    _loadInitialStatus();
  }

  String get _recruiterEmail => _ref.read(currentRecruiterUserEmailProvider);

  Future<void> _loadInitialStatus() async {
    try {
      final job = await _firebaseService.getJobById(jobId, _recruiterEmail);
      state = AsyncValue.data(job?.isActive ?? false);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
  Future<void> toggleStatus() async {
    try {
      final currentStatus = state.value ?? false;
      state = const AsyncValue.loading();
      await _firebaseService.updateJobStatus(jobId, !currentStatus, _recruiterEmail);
      state = AsyncValue.data(!currentStatus);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }
}
// Provider for recent jobs (last 3)
final recentJobsProvider = StreamProvider<List<JobModel>>((ref) {
  final firebaseService = ref.read(firebaseServiceProvider);
  final recruiterEmail = ref.watch(currentRecruiterUserEmailProvider);
  
  if (recruiterEmail.isEmpty) return Stream.value([]);
  
  return firebaseService.getRecentJobs(recruiterEmail, limit: 3);
});

// Provider for recent jobs with time information
final recentJobsWithTimeProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final firebaseService = ref.read(firebaseServiceProvider);
  final recruiterEmail = ref.watch(currentRecruiterUserEmailProvider);
  
  if (recruiterEmail.isEmpty) return Stream.value([]);
  
  return firebaseService.getRecentJobsWithTime(recruiterEmail, limit: 3);
});

// Provider for recent jobs count
final recentJobsCountProvider = StreamProvider<int>((ref) {
  final recentJobsAsyncValue = ref.watch(recentJobsProvider);
  return recentJobsAsyncValue.when(
    data: (jobs) => Stream.value(jobs.length),
    loading: () => Stream.value(0),
    error: (err, stack) => Stream.error(err, stack),
  );
});
 
// StateNotifier for recent jobs management
class RecentJobsNotifier extends StateNotifier<AsyncValue<List<JobModel>>> {
  final FirebaseService _firebaseService;
  final String _recruiterEmail;

  RecentJobsNotifier(this._firebaseService, this._recruiterEmail) 
      : super(const AsyncValue.loading()) {
    _loadRecentJobs();
  }

  Future<void> _loadRecentJobs() async {
    try {
      final stream = _firebaseService.getRecentJobs(_recruiterEmail, limit: 3);
      // Convert stream to initial data load
      final firstData = await stream.first;
      state = AsyncValue.data(firstData);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> refreshRecentJobs() async {
    state = const AsyncValue.loading();
    await _loadRecentJobs();
  }
}

// Recent jobs notifier provider
final recentJobsNotifierProvider = StateNotifierProvider.family<RecentJobsNotifier, AsyncValue<List<JobModel>>, String>(
  (ref, recruiterEmail) {
    final firebaseService = ref.read(firebaseServiceProvider);
    return RecentJobsNotifier(firebaseService, recruiterEmail);
  },
);

// Simple provider to get recent jobs count as int
final recentJobsCountIntProvider = Provider<int>((ref) {
  final recentJobsAsync = ref.watch(recentJobsProvider);
  return recentJobsAsync.maybeWhen(
    data: (jobs) => jobs.length,
    orElse: () => 0,
  );
});

// Provider for checking if there are any recent jobs
final hasRecentJobsProvider = Provider<bool>((ref) {
  final count = ref.watch(recentJobsCountIntProvider);
  return count > 0;
});

// Provider for the most recent job (single job)
final mostRecentJobProvider = Provider<JobModel?>((ref) {
  final recentJobsAsync = ref.watch(recentJobsProvider);
  return recentJobsAsync.maybeWhen(
    data: (jobs) => jobs.isNotEmpty ? jobs.first : null,
    orElse: () => null,
  );
});

//urgent hiring status

final urgentHiringProvider = StateNotifierProvider.family<UrgentHiringNotifier, AsyncValue<bool>, String>((ref, jobId) {
  final firebaseService = ref.read(firebaseServiceProvider);
  return UrgentHiringNotifier(firebaseService, jobId, ref);
});

class UrgentHiringNotifier extends StateNotifier<AsyncValue<bool>> {
  final FirebaseService _firebaseService;
  final String jobId;
  final Ref _ref;

  UrgentHiringNotifier(this._firebaseService, this.jobId, this._ref) : super(const AsyncValue.loading()) {
    _loadInitialStatus();
  }

  String get _recruiterEmail => _ref.read(currentRecruiterUserEmailProvider);

  Future<void> _loadInitialStatus() async {
    try {
      final job = await _firebaseService.getJobById(jobId, _recruiterEmail);
      state = AsyncValue.data(job?.isUrgentHiring ?? false);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> toggleUrgentHiring() async {
    try {
      final currentStatus = state.value ?? false;
      state = const AsyncValue.loading();
      await _firebaseService.updateUrgentHiringStatus(jobId, !currentStatus, _recruiterEmail);
      state = AsyncValue.data(!currentStatus);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }
}

