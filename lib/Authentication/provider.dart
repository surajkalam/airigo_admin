
import 'package:flutter_riverpod/legacy.dart';
enum UserType { jobseeker, recruiter }
final selectionProvider = StateProvider<UserType>((ref) => UserType.jobseeker);


class LoginState {
  final String emailOrMobile;
  final String password;
  final bool obscurePassword;
  final bool isLoading;

  const LoginState({
    required this.emailOrMobile,
    required this.password,
    required this.obscurePassword,
    required this.isLoading,
  });

  LoginState copyWith({
    String? emailOrMobile,
    String? password,
    bool? obscurePassword,
    bool? isLoading,
  }) {
    return LoginState(
      emailOrMobile: emailOrMobile ?? this.emailOrMobile,
      password: password ?? this.password,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class LoginNotifier extends StateNotifier<LoginState> {
  LoginNotifier()
      : super(
          const LoginState(
            emailOrMobile: '',
            password: '',
            obscurePassword: true,
            isLoading: false,
          ),
        );

  void setEmailOrMobile(String value) {
    state = state.copyWith(emailOrMobile: value);
  }

  void setPassword(String value) {
    state = state.copyWith(password: value);
  }

  void togglePasswordVisibility() {
    state = state.copyWith(obscurePassword: !state.obscurePassword);
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  bool validateForm() {
    final emailOrMobile = state.emailOrMobile.trim();
    final password = state.password.trim();

    if (emailOrMobile.isEmpty) {
      return false;
    }

    // Email validation
    if (emailOrMobile.contains("@")) {
      final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
      if (!emailRegex.hasMatch(emailOrMobile)) {
        return false;
      }
    } else {
      // Mobile validation
      final mobileRegex = RegExp(r'^[0-9]{10}$');
      if (!mobileRegex.hasMatch(emailOrMobile)) {
        return false;
      }
    }

    if (password.isEmpty || password.length < 6) {
      return false;
    }

    return true;
  }

  void clearForm() {
    state = const LoginState(
      emailOrMobile: '',
      password: '',
      obscurePassword: true,
      isLoading: false,
    );
  }
}

final loginProvider = StateNotifierProvider<LoginNotifier, LoginState>(
  (ref) => LoginNotifier(),
);