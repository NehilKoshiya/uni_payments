import 'package:flutter/material.dart';
import 'package:simple_icons/simple_icons.dart';

/// Renders a brand glyph for a payment gateway tile.
///
/// Uses the [Simple Icons](https://simpleicons.org) font for brands that
/// ship with the package (Razorpay, Stripe, Paytm, PayPal, PhonePe, Google
/// Pay, Apple Pay) and falls back to a typographic letter badge for the
/// three brands without coverage (Paystack, Flutterwave, Cashfree).
class BrandIcon extends StatelessWidget {
  const BrandIcon({
    super.key,
    required this.gatewayId,
    required this.tint,
    this.size = 24,
  });

  final String gatewayId;
  final Color tint;
  final double size;

  static const _iconByGateway = <String, IconData>{
    'razorpay': SimpleIcons.razorpay,
    'stripe': SimpleIcons.stripe,
    'paytm': SimpleIcons.paytm,
    'phonepe': SimpleIcons.phonepe,
    'paypal': SimpleIcons.paypal,
    'googlepay': SimpleIcons.googlepay,
    'applepay': SimpleIcons.applepay,
  };

  static const _letterByGateway = <String, String>{
    'paystack': 'P',
    'flutterwave': 'F',
    'cashfree': 'C',
  };

  @override
  Widget build(BuildContext context) {
    final icon = _iconByGateway[gatewayId];
    if (icon != null) {
      return Icon(icon, color: tint, size: size);
    }

    final letter = _letterByGateway[gatewayId] ?? '?';
    return _LetterBadge(letter: letter, tint: tint, size: size);
  }
}

class _LetterBadge extends StatelessWidget {
  const _LetterBadge({
    required this.letter,
    required this.tint,
    required this.size,
  });

  final String letter;
  final Color tint;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(size / 4),
      ),
      child: Text(
        letter,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: size * 0.55,
          height: 1,
        ),
      ),
    );
  }
}
