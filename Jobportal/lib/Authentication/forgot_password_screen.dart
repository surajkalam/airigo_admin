import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jobapp/Authentication/auth_state.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authStateProvider.notifier).clearError();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final email = _emailController.text.trim();
    final authNotifier = ref.read(authStateProvider.notifier);
    final success = await authNotifier.sendPasswordResetEmail(email);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Password reset email sent to $email',
            style: const TextStyle(color: Colors.green),
          ),
          backgroundColor: Colors.white,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: Border.all(color: Colors.green),
        ),
      );
      // Navigate back to the previous screen
      context.pop();
    } else {
      final error = ref.read(authStateProvider).error;
      if (error != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error, style: const TextStyle(color: Colors.red)),
            backgroundColor: Colors.white,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: Border.all(color: Colors.red),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(width * 0.05),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: height * 0.02),
                // App Logo
                SizedBox(
                  height: height * 0.15,
                  width: width * 0.4,
                  child: Image.asset('asset/images/airigojobs.png'),
                ),

                SizedBox(height: height * 0.02),

                // Title
                Text(
                  "Forgot Password?",
                  style: GoogleFonts.poppins(
                    fontSize: width * 0.06,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: height * 0.01),
                Text(
                  "Enter your email address and we'll send you a link to reset your password.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: width * 0.035,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: height * 0.04),

                // Email field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  showCursor: true,
                  cursorColor: colorScheme.onSurface.withValues(alpha: 0.6),
                  cursorHeight: 15,
                  decoration: InputDecoration(
                    labelText: "E-mail",
                    labelStyle: textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    hintText: "Enter your email",
                    hintStyle: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.6,
                      ),
                    ),
                    filled: true,
                    fillColor: colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colorScheme.outline),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colorScheme.outline),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colorScheme.primary),
                    ),
                    prefixIcon: Icon(
                      Icons.email,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your email";
                    } else if (!value.contains("@")) {
                      return "Please enter a valid email";
                    }
                    return null;
                  },
                ),
                SizedBox(height: height * 0.04),

                // Send Reset Email Button
                SizedBox(
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
                    onPressed: _sendResetEmail,
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
                            "Send Reset Email",
                            style: GoogleFonts.poppins(
                              fontSize: width * 0.035,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onTertiary,
                            ),
                          ),
                  ),
                ),
                SizedBox(height: height * 0.02),

                // Back to Login
                Center(
                  child: TextButton(
                    onPressed: () => context.pop(),
                    child: Text(
                      "Back to Login",
                      style: GoogleFonts.poppins(
                        fontSize: width * 0.035,
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
