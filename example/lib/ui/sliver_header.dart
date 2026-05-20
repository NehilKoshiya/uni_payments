import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Brand header at the top of the demo home screen — logo mark, gradient
/// title and tagline.
class SliverHeader extends StatelessWidget {
  /// Create the brand header.
  const SliverHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _LogoMark(),
              const SizedBox(width: 12),
              Text(
                'Uni Payments',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              const _VersionPill(),
            ],
          ),
          const SizedBox(height: 24),
          ShaderMask(
            shaderCallback: (rect) => const LinearGradient(
              colors: [AppTheme.brandStart, AppTheme.brandEnd],
            ).createShader(rect),
            child: Text(
              'One API.\nTen gateways.',
              style: textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1.05,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Razorpay · Stripe · PayPal · Paystack · Flutterwave · Paytm · '
            'Cashfree · PhonePe · Google Pay · Apple Pay — all behind a '
            'single Future<PaymentResult>.',
            style: textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.75),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoMark extends StatelessWidget {
  const _LogoMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          colors: [AppTheme.brandStart, AppTheme.brandEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Icon(Icons.bolt_rounded, color: Colors.white),
    );
  }
}

class _VersionPill extends StatelessWidget {
  const _VersionPill();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Text(
        'v1.0.0',
        style: textTheme.labelSmall?.copyWith(
          color: Colors.white.withValues(alpha: 0.75),
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}
