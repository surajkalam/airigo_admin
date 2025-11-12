import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen2 extends ConsumerWidget {
  const OnboardingScreen2({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var height=MediaQuery.of(context).size.height;
    var width=MediaQuery.of(context).size.width;
    
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
          padding: EdgeInsets.symmetric(horizontal: width*0.028),
          child: Column(
            children: [
              SizedBox(height:height*0.043),
              Container(
                width: double.infinity,
                height: height*0.33,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: const DecorationImage(
                    image: AssetImage('asset/images/start2.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
               SizedBox(height: height*0.04),
               Text(
                'Easy Application Process',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                  height: 1.3,
                ),
              ),
               SizedBox(height:height*0.019),
               Text(
                'Apply to multiple jobs with just one tap. Save\ntime and track your applications effortlessly.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              SizedBox(height: height*0.032),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: width*0.016,
                    height: height*0.008,
                    decoration: BoxDecoration(
                      color: colorScheme.outline,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  SizedBox(width: 8),
                  Container(
                    width: width*0.04,
                    height: height*0.01,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  SizedBox(width: width*0.01),
                  Container(
                    width: width*0.024,
                    height: height*0.01,
                    decoration: BoxDecoration(
                      color: colorScheme.outline,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                 SizedBox(width:width*0.01),
                  Container(
                   width: width*0.024,
                    height: height*0.01,
                    decoration: BoxDecoration(
                      color: colorScheme.outline,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
              // SizedBox(height: height * 0.08), // Replaced Spacer with SizedBox
              Spacer(),
              SizedBox(
                width: double.infinity,
                height: height*0.062,
                child: ElevatedButton(
                  onPressed: () {
                    context.push('/on-board3');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Next',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(height: height*0.016),
            ],
          ),
        ),
      ),
    );
  }
}