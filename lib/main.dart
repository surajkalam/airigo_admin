import 'dart:developer';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobapp/Feature/combomodel/combo_gorouter.dart';
import 'package:jobapp/core/material_theme.dart';
import 'package:jobapp/core/typography.dart';
import 'package:jobapp/core/services/local_storage_service.dart';
import 'package:jobapp/core/providers/theme_provider.dart';

import 'package:jobapp/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseAppCheck.instance.activate(
    // ignore: deprecated_member_use
    androidProvider: AndroidProvider.playIntegrity,
  );
  await LocalStorageService().init();
  log('message: Firebase Initialized');
  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerStatefulWidget {
  const MainApp({super.key});
  @override
  ConsumerState<MainApp> createState() => _MainAppState();
}

class _MainAppState extends ConsumerState<MainApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final materialTheme = MaterialTheme(textTheme);
    ThemeMode themeMode;
    try {
      themeMode = ref.watch(themeModeProvider);
    } catch (e) {
      themeMode = ThemeMode.system;
    }
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: materialTheme.light(),
      darkTheme: materialTheme.dark(),
      themeMode: themeMode,
      routerConfig: JobPortalAppRouter.router,
    );
  }
}
