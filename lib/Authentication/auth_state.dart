import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:jobapp/core/services/local_storage_service.dart';

final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthState>((
  ref,
) {
  return AuthStateNotifier();
});

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;
  final bool isLoggedIn;

  AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isLoggedIn = false,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    bool? isLoggedIn,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }
}

class AuthStateNotifier extends StateNotifier<AuthState> {
  AuthStateNotifier() : super(AuthState()) {
    // Check if user is already logged in when the app starts
    _checkCurrentUser();
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final LocalStorageService _localStorage = LocalStorageService();

  // Check current user on app start
  void _checkCurrentUser() {
    final currentUser = _auth.currentUser;
    final isLoggedInLocally = _localStorage.isLoggedIn;

    if (currentUser != null && isLoggedInLocally) {
      state = state.copyWith(user: currentUser, isLoggedIn: true);
    }
  }

  // Sign up with email and password
  Future<User?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String phoneNumber,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password,
          );

      await userCredential.user?.updateDisplayName(phoneNumber);

      // Save user data to local storage
      await _localStorage.setUserEmail(email);
      await _localStorage.setLoggedIn(true);

      state = state.copyWith(
        user: userCredential.user,
        isLoading: false,
        isLoggedIn: true,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Sign up failed. Please try again.';

      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'This email is already registered.';
          break;
        case 'invalid-email':
          errorMessage = 'Please enter a valid email address.';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Email/password accounts are not enabled.';
          break;
        case 'weak-password':
          errorMessage = 'Password is too weak.';
          break;
        default:
          errorMessage = e.message ?? 'An unexpected error occurred.';
      }

      state = state.copyWith(error: errorMessage, isLoading: false);
      return null;
    } catch (e) {
      state = state.copyWith(
        error: 'An unexpected error occurred.',
        isLoading: false,
      );
      return null;
    }
  }

  // Login with email and password
  Future<User?> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email.trim(), password: password);

      // Save user data to local storage
      await _localStorage.setUserEmail(email);
      await _localStorage.setLoggedIn(true);

      state = state.copyWith(
        user: userCredential.user,
        isLoading: false,
        isLoggedIn: true,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Login failed. Please try again.';

      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email.';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password.';
          break;
        case 'invalid-email':
          errorMessage = 'Please enter a valid email address.';
          break;
        case 'user-disabled':
          errorMessage = 'This user account has been disabled.';
          break;
        default:
          errorMessage = e.message ?? 'An unexpected error occurred.';
      }

      state = state.copyWith(error: errorMessage, isLoading: false);
      return null;
    } catch (e) {
      state = state.copyWith(
        error: 'An unexpected error occurred.',
        isLoading: false,
      );
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      // Clear user data from local storage
      await _localStorage.clearAllUserData();
      state = state.copyWith(user: null, isLoggedIn: false);
    } catch (e) {
      state = state.copyWith(error: 'Failed to sign out.');
    }
  }

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Check if user is logged in
  bool isLoggedIn() {
    return _auth.currentUser != null && _localStorage.isLoggedIn;
  }

  // Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _auth.sendPasswordResetEmail(email: email.trim());
      state = state.copyWith(isLoading: false);
      return true;
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Failed to send reset email. Please try again.';

      switch (e.code) {
        case 'invalid-email':
          errorMessage = 'Please enter a valid email address.';
          break;
        case 'user-not-found':
          errorMessage = 'No user found with this email address.';
          break;
        default:
          errorMessage = e.message ?? 'An unexpected error occurred.';
      }

      state = state.copyWith(error: errorMessage, isLoading: false);
      return false;
    } catch (e) {
      state = state.copyWith(
        error: 'An unexpected error occurred.',
        isLoading: false,
      );
      return false;
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}
