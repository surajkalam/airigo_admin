import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:jobapp/core/services/local_storage_service.dart';

class CheckLoginSignupScreen extends ConsumerStatefulWidget {
  const CheckLoginSignupScreen({super.key});

  @override
  ConsumerState<CheckLoginSignupScreen> createState() =>
      _CheckLoginSignupScreenState();
}

class _CheckLoginSignupScreenState
    extends ConsumerState<CheckLoginSignupScreen> {

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final localStorage = LocalStorageService();
    final isLoggedIn = localStorage.isLoggedIn;
    final userType = localStorage.userType;

    if (isLoggedIn && userType == 'admin') {
      // Delay navigation to ensure proper initialization
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/admin-dashboard');
      });
    }
  }

  void _navigateToLogin() {
    context.push('/login', extra: 'admin');
  }

  void _navigateToSignup() {
    context.push('/signup', extra: 'admin');
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(padding: EdgeInsets.only(top: height * 0.1)),
                    SizedBox(height: height * 0.05),
                    Center(
                      child: Container(
                        height: height * 0.06,
                        width: width * 0.6,
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: BorderRadius.circular(width * 0.05),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.shadow.withValues(
                                alpha: 0.2,
                              ),
                              spreadRadius: 1,
                              blurRadius: 6,
                              offset: const Offset(1, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            "Admin Portal",
                            style: GoogleFonts.poppins(
                              fontSize: width * 0.05,
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: width * 0.02,
                        vertical: height * 0.06,
                      ),
                      child: Column(
                        children: [
                          // Login Button
                          GestureDetector(
                            onTap: _navigateToLogin,
                            child: Container(
                              height: height * 0.06,
                              width: width * 0.5,
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                borderRadius: BorderRadius.circular(
                                  width * 0.02,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: colorScheme.shadow.withValues(
                                      alpha: 0.3,
                                    ),
                                    spreadRadius: 2,
                                    blurRadius: 8,
                                    offset: const Offset(2, 3),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  "Login",
                                  style: GoogleFonts.poppins(
                                    fontSize: width * 0.04,
                                    color: colorScheme.onPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: height * 0.04),
                          // SignUp Button
                          GestureDetector(
                            onTap: _navigateToSignup,
                            child: Container(
                              height: height * 0.06,
                              width: width * 0.5,
                              decoration: BoxDecoration(
                                color: colorScheme.surface.withValues(
                                  alpha: 0.9,
                                ),
                                border: Border.all(
                                  color: colorScheme.primary,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(
                                  width * 0.02,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: colorScheme.shadow.withValues(
                                      alpha: 0.2,
                                    ),
                                    spreadRadius: 1,
                                    blurRadius: 6,
                                    offset: const Offset(1, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  "SignUp",
                                  style: GoogleFonts.poppins(
                                    fontSize: width * 0.04,
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: height * 0.09),
                          // Text with better visibility on background
                          Column(
                            children: [
                              Text(
                                "your journey starts today.",
                                style: GoogleFonts.lora(
                                  fontSize: width * 0.042,
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.w700,
                                ),
                                textAlign: TextAlign.center,
                                softWrap: true,
                              ),
                              SizedBox(height: height * 0.01),
                              Text(
                                "Fresh beginnings, Bright opportunities.",
                                style: GoogleFonts.lora(
                                  fontSize: width * 0.042,
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.w700,
                                ),
                                textAlign: TextAlign.center,
                                softWrap: true,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
