// routes/app_router.dart
import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:jobapp/Feature/AdminSide/admindashboard_screen.dart';

class JobPortalAppRouter {
  static final GoRouter router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (context, state) => const AdminDashboardScreen()),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Page not found: ${state.error}'))),
  );
}
