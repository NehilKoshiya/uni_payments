import 'dart:ui';

/// A purely-presentational description of a gateway tile for the demo UI.
///
/// The icon glyph is resolved by `BrandIcon` from the [id] — no per-tile
/// asset path needed.
class Gateway {
  const Gateway({
    required this.id,
    required this.name,
    required this.tagline,
    required this.tint,
  });

  /// Stable id used both as the brand-icon key and as the dispatch key in
  /// the home screen.
  final String id;
  final String name;
  final String tagline;
  final Color tint;
}

const demoGateways = <Gateway>[
  Gateway(
    id: 'razorpay',
    name: 'Razorpay',
    tagline: 'Cards · UPI · wallets',
    tint: Color(0xFF3395FF),
  ),
  Gateway(
    id: 'stripe',
    name: 'Stripe',
    tagline: 'Global PaymentSheet',
    tint: Color(0xFF635BFF),
  ),
  Gateway(
    id: 'paypal',
    name: 'PayPal',
    tagline: 'Braintree drop-in',
    tint: Color(0xFFFFC439),
  ),
  Gateway(
    id: 'paystack',
    name: 'Paystack',
    tagline: 'Africa-first checkout',
    tint: Color(0xFF00C3F7),
  ),
  Gateway(
    id: 'flutterwave',
    name: 'Flutterwave',
    tagline: 'Pan-African gateway',
    tint: Color(0xFFFB6020),
  ),
  Gateway(
    id: 'paytm',
    name: 'Paytm',
    tagline: 'All-in-One India',
    tint: Color(0xFF00BAF2),
  ),
  Gateway(
    id: 'cashfree',
    name: 'Cashfree',
    tagline: 'India · server-driven',
    tint: Color(0xFF6933FF),
  ),
  Gateway(
    id: 'phonepe',
    name: 'PhonePe',
    tagline: 'UPI · India',
    tint: Color(0xFF5F259F),
  ),
  Gateway(
    id: 'googlepay',
    name: 'Google Pay',
    tagline: 'Tokenized wallet',
    tint: Color(0xFF4285F4),
  ),
  Gateway(
    id: 'applepay',
    name: 'Apple Pay',
    tagline: 'iOS native wallet',
    tint: Color(0xFF000000),
  ),
];
