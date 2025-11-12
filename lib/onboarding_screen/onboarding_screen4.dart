import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen4 extends ConsumerWidget {
  const OnboardingScreen4({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    
    // Safely access theme colors with fallbacks
    ColorScheme? colorScheme;
    try {
      colorScheme = Theme.of(context).colorScheme;
    } catch (e) {
      // Fallback to default colors if theme is not available
      colorScheme = ColorScheme.light();
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.028),
          child: Column(
            children: [
              SizedBox(height: height * 0.05),
              Container(
                width: double.infinity,
                height: height * 0.3,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: const DecorationImage(
                    image: AssetImage('asset/images/start4.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: height * 0.043),
              Text(
                'Start Your Career\nJourney',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                  height: 1.3,
                ),
              ),
              SizedBox(height: height * 0.016),
              Text(
                'Join millions of professionals finding their\nperfect job match every day.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              SizedBox(height: height * 0.038),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: width * 0.02,
                    height: height * 0.01,
                    decoration: BoxDecoration(
                      color: colorScheme.outline,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  SizedBox(width: width * 0.01),
                  Container(
                    width: width * 0.02,
                    height: height * 0.01,
                    decoration: BoxDecoration(
                      color: colorScheme.outline,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  SizedBox(width: width * 0.01),
                  Container(
                    width: width * 0.02,
                    height: height * 0.01,
                    decoration: BoxDecoration(
                      color: colorScheme.outline,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  SizedBox(width: width * 0.01),
                  Container(
                    width: width * 0.05,
                    height: height * 0.01,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
              Spacer(),
              SizedBox(
                width: double.infinity,
                height: height * 0.062,
                child: ElevatedButton(
                  onPressed: () {
                    context.push('/check-login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Get Started',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: width * 0.01),
                      Icon(Icons.arrow_forward, size: 20),
                    ],
                  ),
                ),
              ),
              SizedBox(height: height * 0.055),
            ],
          ),
        ),
      ),
    );
  }
}