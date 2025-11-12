import 'package:flutter/material.dart';

class MaterialTheme {
  final TextTheme textTheme;

  MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return ColorScheme(
      brightness: Brightness.light,
      //primary: Color(0xFF1E293B), // Dark blue-gray (text-primary)
      primary: Color(0xFF48A6A7),
      onPrimary: Color(0xFFF8FAFC), // Light gray (bg-primary)
      primaryContainer: Color(0xFFE2E8F0), // Light blue-gray (for containers)
      onPrimaryContainer: Color(
        0xFF0F172A,
      ), // Darker shade for text on containers
      secondary: Color(0xFF64748B), // Medium gray (text-secondary)
      onSecondary: Color(0xFF6366F1), // Indigo (accent-primary)
      secondaryContainer: Color(
        0xFFE2E8F0,
      ), // Light container for secondary elements
      onSecondaryContainer: Color(
        0xFF334155,
      ), // Dark text on secondary containers
      tertiary: Color(0xFFD39539), // Amber (accent-secondary)
      tertiaryFixed: const Color(0xFF59AC77), // green
      onTertiary: Color(0xFFFFFFFF), // White text on tertiary
      tertiaryContainer: Color(0xFFFFE0B2), // Light amber container
      onTertiaryContainer: Color(
        0xFF5D4037,
      ), // Dark text on tertiary containers
      error: Colors.red, // Error color
      onError: Colors.white, // Text on error
      errorContainer: Color(0xFFFECDD3), // Light red container for errors
      onErrorContainer: Color(0xFFB91C1C), // Dark text on error containers
      surface: Color(0xFFFFFFFF), // White background (bg-secondary, bg-card)
      onSurface: Colors.black, // Black text on surface
      surfaceContainerHighest: Color(
        0xFFE2E8F0,
      ), // Light variant surface (border-color)
      onSurfaceVariant: Color(
        0xFF475569,
      ), // Medium-dark text on variant surfaces
      outline: Color(0xFFCBD5E1), // Border outline
      outlineVariant: Color(0xFFE2E8F0), // Variant outline
      shadow: Color(0xFF000000), // Shadow color
      scrim: Color(0xFF000000), // Scrim color
      inverseSurface: Color(0xFF2E2E2E), // Inverse surface
      onInverseSurface: Color(0xFFF5F5F5), // Text on inverse surface
      inversePrimary: Color(0xFF60A5FA), // Inverse primary
      surfaceTint: Color(0xFF1E293B), // Surface tint
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme darkScheme() {
    return ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFFF1F5F9), // Light gray (text-primary)
      onPrimary: Color(0xFF0F172A), // Dark blue (bg-primary)
      primaryContainer: Color(0xFF1E293B), // Darker blue container
      onPrimaryContainer: Color(0xFFE2E8F0), // Light text on containers
      secondary: Color(0xFF94A3B8), // Light medium gray (text-secondary)
      onSecondary: Color(0xFF818CF8), // Light indigo (accent-primary)
      secondaryContainer: Color(
        0xFF334155,
      ), // Dark container for secondary elements
      onSecondaryContainer: Color(
        0xFFE2E8F0,
      ), // Light text on secondary containers
      tertiary: Color(0xFFF5BF0F), // Bright amber (accent-secondary)
      onTertiary: Color(0xFF000000), // Black text on tertiary
      tertiaryContainer: Color(0xFF5D4037), // Dark amber container
      onTertiaryContainer: Color(
        0xFFFFE0B2,
      ), // Light text on tertiary containers
      error: Colors.red, // Error color
      onError: Colors.white, // Text on error
      errorContainer: Color(0xFFB91C1C), // Dark red container for errors
      onErrorContainer: Color(0xFFFECDD3), // Light text on error containers
      surface: Color(
        0xFF1E293B,
      ), // Dark blue-gray background (bg-secondary, bg-card)
      onSurface: Colors.white, // White text on surface
      surfaceContainerHighest: Color(
        0xFF334155,
      ), // Darker variant surface (border-color)
      onSurfaceVariant: Color(0xFFCBD5E1), // Light text on variant surfaces
      outline: Color(0xFF475569), // Border outline
      outlineVariant: Color(0xFF334155), // Variant outline
      shadow: Color(0xFF000000), // Shadow color
      scrim: Color(0xFF000000), // Scrim color
      inverseSurface: Color(0xFFF5F5F5), // Inverse surface
      onInverseSurface: Color(0xFF2E2E2E), // Text on inverse surface
      inversePrimary: Color(0xFF60A5FA), // Inverse primary
      surfaceTint: Color(0xFFF1F5F9), // Surface tint
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  ThemeData theme(ColorScheme colorScheme) => ThemeData(
    useMaterial3: true,
    fontFamily: 'Roboto',
    brightness: colorScheme.brightness,
    colorScheme: colorScheme,
    textTheme: textTheme.apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    ),
    scaffoldBackgroundColor: colorScheme.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      elevation: 0,
      titleTextStyle: textTheme.titleLarge?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: colorScheme.onSurface),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor:
            colorScheme.tertiary, // Using amber as primary button color
        foregroundColor: colorScheme.onTertiary,
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colorScheme.onSecondary,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colorScheme.onSurface,
        side: BorderSide(color: colorScheme.outline),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
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
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.error, width: 2),
      ),
      labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
      // ignore: deprecated_member_use
      hintStyle: TextStyle(
        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
      ),
    ),
    cardTheme: CardThemeData(
      color: colorScheme.surface,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outline, width: 1),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: colorScheme.inverseSurface,
      contentTextStyle: TextStyle(color: colorScheme.onInverseSurface),
      actionTextColor: colorScheme.tertiary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: colorScheme.surface,
      titleTextStyle: TextStyle(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.bold,
      ),
      contentTextStyle: TextStyle(color: colorScheme.onSurfaceVariant),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}
