import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(),
);

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeModeIndex = prefs.getInt('theme_mode') ?? 0;
      // Ensure the index is within valid range
      if (themeModeIndex >= 0 && themeModeIndex < ThemeMode.values.length) {
        state = ThemeMode.values[themeModeIndex];
      } else {
        state = ThemeMode.system;
      }
    } catch (e) {
      // Fallback to system theme if there's an error
      state = ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    try {
      state = themeMode;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('theme_mode', themeMode.index);
    } catch (e) {
      // Silently fail if we can't save to prefs
      debugPrint('Failed to save theme mode: $e');
    }
  }

  void toggleTheme() {
    try {
      if (state == ThemeMode.light) {
        setThemeMode(ThemeMode.dark);
      } else if (state == ThemeMode.dark) {
        setThemeMode(ThemeMode.light);
      } else {
        // If system mode, toggle to opposite of system
        final isSystemDark = WidgetsBinding.instance.window.platformBrightness == Brightness.dark;
        setThemeMode(isSystemDark ? ThemeMode.light : ThemeMode.dark);
      }
    } catch (e) {
      // Fallback to light theme if toggle fails
      setThemeMode(ThemeMode.light);
    }
  }
}