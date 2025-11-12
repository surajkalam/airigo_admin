import 'dart:developer';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jobapp/Authentication/auth_state.dart';
import 'package:jobapp/Authentication/provider.dart';
import 'package:jobapp/core/services/local_storage_service.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final String option;
  const LoginScreen({super.key, required this.option});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailOrMobileController =
      TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final LocalStorageService _localStorage = LocalStorageService();

  bool _obscurePassword = true;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authStateProvider.notifier).clearError();
    });
  }

  @override
  void dispose() {
    _emailOrMobileController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _navigateToSignup(BuildContext context) {
    final userType = ref.read(selectionProvider);
    context.go('/signup', extra: userType.name);
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final userType = ref.read(selectionProvider);
    final email = _emailOrMobileController.text.trim();
    final password = _passwordController.text.trim();
    final authNotifier = ref.read(authStateProvider.notifier);
    try {
      log("🔄 Attempting login as: $userType with email: $email");

      final user = await authNotifier.loginWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (user != null) {
        log("✅ Login successful for: ${user.email}");
        final userEmail = user.email ?? email;

        // Save user data to local storage
        await _localStorage.setUserEmail(userEmail);
        await _localStorage.setUserType(userType.name);
        await _localStorage.setLoggedIn(true);
        if (mounted) {
          _showSnackBar(
            context: context,
            text: '✅ Login successful for: $userEmail',
          );
        }
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (userType == UserType.jobseeker) {
            context.go('/job-nav');
          } else {
            context.go('/recuiter-nav');
          }
        });
      } else {
        final error = ref.read(authStateProvider).error;
        log("🔴 Login failed with error: $error");
        if (error != null && mounted) {
          _showSnackBar(
            context: context,
            text: 'Login failed: ${_getErrorMessage(error)}',
            textColor: Colors.red,
          );
        }
      }
    } catch (e) {
      log("🔴 Exception during login: $e");
      if (mounted) {
        _showSnackBar(
          context: context,
          text: 'Login error: ${_getErrorMessage(e.toString())}',
          textColor: Colors.red,
        );
      }
    }
  }

  String _getErrorMessage(dynamic error) {
    final errorString = error.toString();

    if (errorString.contains('invalid-credential') ||
        errorString.contains('supplied auth credential is incorrect')) {
      return 'Invalid email or password';
    } else if (errorString.contains('user-not-found')) {
      return 'No account found with this email';
    } else if (errorString.contains('wrong-password')) {
      return 'Incorrect password';
    } else if (errorString.contains('network-request-failed')) {
      return 'Network error. Please check your connection';
    } else {
      return 'Login failed. Please try again';
    }
  }

  @override
  Widget build(BuildContext context) {
    final userType = ref.watch(selectionProvider);
    final authState = ref.watch(authStateProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(width * 0.05),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Header with user type
                Padding(
                  padding: EdgeInsets.only(top: height * 0.01),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: width * 0.04,
                          vertical: height * 0.005,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          userType.name.toUpperCase(),
                          style: GoogleFonts.poppins(
                            fontSize: width * 0.03,
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: height * 0.01),
                // App Logo
                SizedBox(
                  height: height * 0.15,
                  width: width * 0.4,
                  child: Image.asset('asset/images/airigojobs.png'),
                ),

                SizedBox(height: height * 0.01),

                // Welcome Text
                Text(
                  "Welcome Back!",
                  style: GoogleFonts.poppins(
                    fontSize: width * 0.06,
                    fontWeight: FontWeight.bold,
                    color:
                        colorScheme.onSurface, // Changed from AppColors.black
                  ),
                ),
                SizedBox(height: height * 0.01),
                Text(
                  "Login to your account",
                  style: GoogleFonts.poppins(
                    fontSize: width * 0.035,
                    color: colorScheme
                        .onSurfaceVariant, // Changed from AppColors.grey
                  ),
                ),
                SizedBox(height: height * 0.04),

                // Email field
                TextFormField(
                  controller: _emailOrMobileController,
                  keyboardType: TextInputType.emailAddress,
                  showCursor: true,
                  cursorColor: colorScheme.onSurface.withValues(
                    alpha: 0.6,
                  ), // Changed from AppColors.black.withValues(alpha: 0.6)
                  cursorHeight: 15,
                  decoration: InputDecoration(
                    labelText: "E-mail",
                    labelStyle: textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                      color: colorScheme
                          .onSurfaceVariant, // Changed from AppColors.black.withValues(alpha: 0.6)
                    ),
                    hintText: "Enter your email",
                    hintStyle: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.6,
                      ), // Changed from AppColors.black.withValues(alpha: 0.6)
                    ),
                    filled: true,
                    fillColor:
                        colorScheme.surface, // Changed from AppColors.white
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: colorScheme
                            .outline, // Changed from AppColors.grey.withValues(alpha: 0.5)
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: colorScheme
                            .outline, // Changed from AppColors.grey.withValues(alpha: 0.5)
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: colorScheme
                            .primary, // Changed from AppColors.grey.withValues(alpha: 0.8)
                      ),
                    ),
                    prefixIcon: Icon(
                      Icons.email,
                      color: colorScheme
                          .onSurfaceVariant, // Changed from AppColors.grey.withValues(alpha: 0.7)
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your email";
                    } else if (!value.contains("@")) {
                      return "Please enter a valid email";
                    }
                    //   } else if (!RegExp(
                    //     r'^[^@]+@[^@]+\.[^@]+',
                    //   ).hasMatch(value)) {
                    //     return "Please enter a valid email";
                    //   }
                    //   return null;
                  },
                ),
                SizedBox(height: height * 0.02),

                // Password field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: "Password",
                    labelStyle: textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                      color: colorScheme
                          .onSurfaceVariant, // Changed from AppColors.black.withValues(alpha: 0.6)
                    ),
                    hintText: "Enter your password",
                    hintStyle: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.6,
                      ), // Changed from AppColors.black.withValues(alpha: 0.6)
                    ),
                    filled: true,
                    fillColor:
                        colorScheme.surface, // Changed from AppColors.white
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: colorScheme
                            .outline, // Changed from AppColors.grey.withValues(alpha: 0.5)
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: colorScheme
                            .outline, // Changed from AppColors.grey.withValues(alpha: 0.5)
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: colorScheme
                            .primary, // Changed from AppColors.grey.withValues(alpha: 0.8)
                      ),
                    ),
                    prefixIcon: Icon(
                      Icons.lock,
                      color: colorScheme
                          .onSurfaceVariant, // Changed from AppColors.grey.withValues(alpha: 0.7)
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: colorScheme
                            .onSurfaceVariant, // Changed from AppColors.grey.withValues(alpha: 0.7)
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter a password";
                    } else if (value.length < 6) {
                      return "Password must be at least 6 characters";
                    }
                    return null;
                  },
                ),
                SizedBox(height: height * 0.02),

                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      context.push('/forgot-password');
                    },
                    child: Text(
                      "Forgot Password?",
                      style: GoogleFonts.poppins(
                        fontSize: width * 0.03,
                        color: colorScheme.primary, // This was already correct
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: height * 0.04),
                // Login Button
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: width * 0.03),
                        backgroundColor: colorScheme.tertiary,
                        foregroundColor: colorScheme.onTertiary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _handleLogin,
                      child: authState.isLoading
                          ? SizedBox(
                              height: height * 0.015,
                              width: width * 0.035,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colorScheme.onTertiary,
                              ),
                            )
                          : Text(
                              "Login",
                              style: GoogleFonts.poppins(
                                fontSize: width * 0.035,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onTertiary,
                              ),
                            ),
                    ),
                  ),
                ),
                SizedBox(height: height * 0.02),
                // Signup navigation
                Center(
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.poppins(
                        fontSize: width * 0.035,
                        color: colorScheme.onSurface,
                      ),
                      children: [
                        const TextSpan(text: "Don't have an account? "),
                        TextSpan(
                          text: "Sign Up",
                          style: GoogleFonts.poppins(
                            color:
                                colorScheme.primary, // This was already correct
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => _navigateToSignup(context),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: height * 0.04),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: InkWell(
                        onTap: () {
                          context.pushReplacement('/check-login');
                        },
                        child: Text(
                          'change role',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSnackBar({
    required BuildContext context,
    required String text,
    Color backgroundColor = Colors.white,
    Color textColor = Colors.green,
    Duration duration = const Duration(seconds: 4),
    SnackBarBehavior behavior = SnackBarBehavior.floating,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: behavior,
        margin: EdgeInsets.all(12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: textColor),
        ),
      ),
    );
  }
}
