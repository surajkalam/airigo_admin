// routes/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jobapp/Authentication/Signupscreen.dart';
import 'package:jobapp/Authentication/checkloginsignup.dart';
import 'package:jobapp/Authentication/loginscreen.dart';
import 'package:jobapp/Feature/Recuiter/Widget/recuiternavbar.dart';
import 'package:jobapp/Feature/Recuiter/screens/job_details.dart';
import '../../Recuiter/recuiter_model/recuiter_model.dart';
import '../jobseekers_screens/jobseekers_screens.dart';
import 'Widget.dart';
class JobseekeerAppRouter {
  static final GoRouter router = GoRouter(
    routes:[
      GoRoute(
        path: '/',
        builder: (context, state) => CheckLoginSignupScreen(),
      ),
      // GoRoute(
      //   path: '/',
      //   builder: (context, state) =>OnboardingScreen1(),
      // ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) {
          final option = state.extra as String? ?? 'jobseeker';
          return LoginScreen(option: option);
        },
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) {
          final option = state.extra as String? ?? 'jobseeker';
          return SignupScreen(option: option);
        },
      ),
      GoRoute(
        path: '/job-nav',
        builder: (context, state) => JobseekerNavbar(),
      ),
      GoRoute(
        path: '/recuiter-nav',
        builder: (context, state) => RecruiterNavbar(),
      ),
      GoRoute(
        path: '/job-details',
        builder: (context, state) {
          final job = state.extra as JobModel?;
          if(job == null){
            return Scaffold(
              body: Center(child: Text('No job data provided')),
            );
          }
          return JobDetailsScreen(job: job);
        },
      ),
       GoRoute(
        path: '/uploaddetail-job',
        builder: (context, state) {
          return JobuploaddetailScreen();
        },
      ),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Page not found: ${state.error}'))),
  );
}