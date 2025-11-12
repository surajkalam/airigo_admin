import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
class OnboardingScreen3 extends ConsumerWidget {
  const OnboardingScreen3({super.key});

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
              SizedBox(height: height*0.043),
              Container(
                width: width*0.65,
                height: height*0.3,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.people_outline,
                    size: 80,
                    color: colorScheme.primary,
                  ),
                ),
              ),
               SizedBox(height:height*0.065),
               Text(
                'Connect with Top\nEmployers',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                  height: 1.3,
                ),
              ),
            SizedBox(height:height*0.019),
              const Text(
                'Get noticed by leading companies and receive\npersonalized job recommendations.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
              SizedBox(height: height*0.039),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: width*0.02,
                    height: height*0.01,
                    decoration: BoxDecoration(
                      color: colorScheme.outline,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                SizedBox(width: width*0.01),
                  Container(
                   width: width*0.02,
                    height: height*0.01,
                    decoration: BoxDecoration(
                      color: colorScheme.outline,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: width*0.05,
                    height: height*0.01,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: width*0.02,
                    height: height*0.01,
                    decoration: BoxDecoration(
                      color: colorScheme.outline,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
              Spacer(),
              SizedBox(
                width: double.infinity,
                height: height*0.062,
                child: ElevatedButton(
                  onPressed: () {
                    context.push('/on-board4');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child:  Text(
                    'Next',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(height: height*0.016)
            ],
          ),
        ),
      ),
    );
  }
}