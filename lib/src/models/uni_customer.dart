import 'package:flutter/foundation.dart';

/// The buyer's profile used to prefill checkout forms across gateways.
///
/// Defining this once and reusing it for every call removes the per-gateway
/// `email` / `name` / `phone` parameter sprawl that the old API had.
@immutable
class UniCustomer {
  /// Create a [UniCustomer]. [name] and [email] are required because every
  /// supported gateway needs at least those two; [phone] is optional and is
  /// forwarded only to gateways that accept it.
  const UniCustomer({required this.name, required this.email, this.phone});

  /// Full name shown on the checkout sheet.
  final String name;

  /// Email used for receipts + risk scoring.
  final String email;

  /// E.164 phone number. Some gateways (Razorpay, Flutterwave, Paytm) prefill
  /// it on the checkout; others (Stripe, Braintree) ignore it.
  final String? phone;

  @override
  String toString() => 'UniCustomer(name: $name, email: $email, phone: $phone)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UniCustomer &&
          other.name == name &&
          other.email == email &&
          other.phone == phone;

  @override
  int get hashCode => Object.hash(name, email, phone);
}
