// jobseeker_providers.dart
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:jobapp/Authentication/user_provider.dart';
import 'package:jobapp/Feature/JobSeeker/firebase_crud/jobseeker_infofire.dart';
import 'package:jobapp/Feature/JobSeeker/modelclass/jobseeker_info.dart';

// Current User Provider with default email

final jobseekerIdProvider = Provider<String>((ref) {
  return ref.read(currentUserProvider);
});

// Jobseeker Firebase Service Provider
final jobseekerFirebaseServiceProvider = Provider<JobseekerFirebaseService>((
  ref,
) {
  return JobseekerFirebaseService();
});

// Jobseeker State
class JobseekerState {
  final JobseekerModel? jobseekerInfo;
  final bool isLoading;
  final String? error;
  final bool success;

  const JobseekerState({
    this.jobseekerInfo,
    this.isLoading = false,
    this.error,
    this.success = false,
  });

  JobseekerState copyWith({
    JobseekerModel? jobseekerInfo,
    bool? isLoading,
    String? error,
    bool? success,
  }) {
    return JobseekerState(
      jobseekerInfo: jobseekerInfo ?? this.jobseekerInfo,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      success: success ?? this.success,
    );
  }
}

// Jobseeker Notifier
class JobseekerNotifier extends StateNotifier<JobseekerState> {
  final JobseekerFirebaseService _firebaseService;
  final Ref _ref;

  JobseekerNotifier(this._firebaseService, this._ref)
    : super(const JobseekerState());

  String get _currentUserEmail {
    final email = _ref.read(currentUserProvider);
    if (email.isEmpty) {
      throw Exception('User email is not available. Please log in first.');
    }
    return email;
  }

  Future<void> loadJobseekerInfo() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final jobseekerInfo = await _firebaseService.getJobseekerInfo(
        _currentUserEmail,
      );

      state = state.copyWith(jobseekerInfo: jobseekerInfo, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load jobseeker info: $e',
      );
    }
  }

  Future<void> saveJobseekerInfo(JobseekerModel jobseekerInfo) async {
    try {
      state = state.copyWith(isLoading: true, error: null, success: false);

      await _firebaseService.saveJobseekerInfo(
        jobseekerInfo,
        _currentUserEmail,
      );

      state = state.copyWith(
        jobseekerInfo: jobseekerInfo,
        isLoading: false,
        success: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to save jobseeker info: $e',
      );
      rethrow;
    }
  }

  Future<void> updateJobseekerInfo(JobseekerModel jobseekerInfo) async {
    try {
      state = state.copyWith(isLoading: true, error: null, success: false);

      await _firebaseService.updateJobseekerInfo(
        jobseekerInfo,
        _currentUserEmail,
      );

      state = state.copyWith(
        jobseekerInfo: jobseekerInfo,
        isLoading: false,
        success: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to update jobseeker info: $e',
      );
      rethrow;
    }
  }

   // Upload resume
  Future<void> uploadResume(File resumeFile) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      // Upload to Firebase Storage
      final resumeUrl = await _firebaseService.uploadResume(resumeFile, _currentUserEmail);
      // Get file name
      final resumeFileName = resumeFile.path.split('/').last;
      // Update resume info in Firestore
      await _firebaseService.updateResumeInfo(_currentUserEmail, resumeUrl, resumeFileName);
      // Reload jobseeker info to get updated data
      await loadJobseekerInfo();
      state = state.copyWith(isLoading: false, success: true);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to upload resume: $e',
      );
      rethrow;
    }
  }

  // Delete resume
  Future<void> deleteResume() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _firebaseService.deleteResume(_currentUserEmail);
      // Reload jobseeker info to get updated data
      await loadJobseekerInfo();
      state = state.copyWith(isLoading: false, success: true);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to delete resume: $e',
      );
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

// Jobseeker Provider
final jobseekerProvider =
    StateNotifierProvider<JobseekerNotifier, JobseekerState>((ref) {
      final firebaseService = ref.read(jobseekerFirebaseServiceProvider);
      return JobseekerNotifier(firebaseService, ref);
    });