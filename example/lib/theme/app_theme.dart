import 'package:flutter/material.dart';

/// Centralised dark-mode theme + design tokens for the demo app.
///
/// The demo only ships a dark theme — payment SDKs render their own
/// modals (Razorpay, Stripe PaymentSheet, etc.) which already respect the
/// system appearance, so the host UI staying dark gives a clean contrast
/// against those sheets.
class AppTheme {
  AppTheme._();

  /// Indigo-500. Used as the primary brand seed colour and the start of
  /// every gradient.
  static const Color brandStart = Color(0xFF6366F1);

  /// Pink-500. End of the brand gradient.
  static const Color brandEnd = Color(0xFFEC4899);

  /// Emerald-500. Reserved for success states.
  static const Color accent = Color(0xFF10B981);

  /// The animated background gradient stops.
  static const List<Color> backgroundGradient = [
    Color(0xFF0B0F1A),
    Color(0xFF1E1B4B),
    Color(0xFF0B0F1A),
  ];

  /// Returns the demo's dark Material 3 theme.
  static ThemeData dark(TextTheme base) {
    final scheme = ColorScheme.fromSeed(
      seedColor: brandStart,
      brightness: Brightness.dark,
    ).copyWith(surface: const Color(0xFF111827));
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: Colors.transparent,
      textTheme: base.apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }
}
