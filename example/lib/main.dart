import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'theme/app_theme.dart';
import 'ui/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const UniPaymentsDemoApp());
}

/// Demo app shell. Dark-mode only — payment SDKs (Razorpay, Stripe,
/// Paytm, …) render their own modals on top, so a uniformly dark host
/// gives the cleanest contrast.
class UniPaymentsDemoApp extends StatelessWidget {
  /// Create the demo app shell.
  const UniPaymentsDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.interTextTheme();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Uni Payments',
      theme: AppTheme.dark(textTheme),
      home: const HomeScreen(),
    );
  }
}
