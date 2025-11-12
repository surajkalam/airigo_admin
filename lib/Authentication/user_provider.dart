import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:jobapp/Authentication/provider.dart';
import 'package:jobapp/core/services/local_storage_service.dart';
import 'auth_state.dart';

// Current user email providers
final currentUserProvider = StateProvider<String>((ref) {
  // Initialize with email from shared preferences if available
  try {
    final localStorage = LocalStorageService();
    return localStorage.userEmail ?? '';
  } catch (e) {
    // If localStorage is not initialized, return empty string
    return '';
  }
});

final currentRecruiterUserEmailProvider = StateProvider<String>((ref) {
  // Initialize with email from shared preferences if available
  try {
    final localStorage = LocalStorageService();
    return localStorage.userEmail ?? '';
  } catch (e) {
    // If localStorage is not initialized, return empty string
    return '';
  }
});

// Fixed auth state listener provider
final authListenerProvider = Provider<void>((ref) {
  final authState = ref.watch(authStateProvider);
  // Use addPostFrameCallback to avoid modifying during build
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final userType = ref.read(selectionProvider);
    // When user logs in, store their email in the appropriate provider
    if (authState.isLoggedIn && authState.user != null) {
      final userEmail = authState.user!.email ?? 'No User';
      if (userType == UserType.jobseeker) {
        ref.read(currentUserProvider.notifier).state = userEmail;
      } else {
        ref.read(currentRecruiterUserEmailProvider.notifier).state = userEmail;
      }
    }
    // When user logs out, clear the providers
    if (!authState.isLoggedIn) {
      ref.read(currentUserProvider.notifier).state = '';
      ref.read(currentRecruiterUserEmailProvider.notifier).state = '';
    }
  });
});