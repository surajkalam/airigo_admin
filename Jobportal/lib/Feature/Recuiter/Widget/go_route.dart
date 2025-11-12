// routes/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/screens.dart';
import 'Widget.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    routes:[
      //  GoRoute(
      //   path: '/',
      //   name: 'info',
      //   builder: (context, state) => RecuiterInfo(),
      // ),
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => RecruiterNavbar(),
      ),
      // GoRoute(
      //   path: '/',
      //   name: 'job_details',
      //   builder: (context, state) => JobdetailScreen(),
      // ),

      // GoRoute(path: '/recuiter-info',
      // name: 'info',
      // builder: (context, state) => RecuiterInfo() ,
      // ),
      // GoRoute(
      //   path: '/recuiter-info',
      //   name: 'info',
      //   builder: (context, state) => RecuiterInfo(),
      // ),
      // GoRoute(
      //   path: '/auth',
      //   name: 'auth',
      //   builder: (context, state) => CheckLoginSignupScreen(),
      // ),
      GoRoute(
        path: '/job-details',
        name: 'job_details',
        builder: (context, state) => JobuploaddetailScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.error}'),
      ),
    ),
  );
}