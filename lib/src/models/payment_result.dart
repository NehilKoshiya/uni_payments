import 'package:flutter/foundation.dart';

/// The outcome of a payment attempt.
///
/// Use Dart's pattern matching to handle each case:
///
/// ```dart
/// final result = await UniPayments.payWithRazorpay(...);
/// switch (result) {
///   case PaymentSuccess(:final transactionId, :final gatewayName):
///     // forward txn to your backend, knowing which gateway sourced it
///   case PaymentFailure(:final errorCode, :final message):
///     // show error
///   case PaymentCancelled():
///     // user dismissed the sheet
/// }
/// ```
@immutable
sealed class PaymentResult {
  /// Base constructor. Subclasses populate [gatewayName] so callers can
  /// branch on the originating gateway without tracking it themselves.
  const PaymentResult({this.gatewayName, this.message, this.rawResponse});

  /// The gateway that produced this result, e.g. `razorpay`, `stripe`.
  /// Always set by the bundled gateway implementations.
  final String? gatewayName;

  /// Optional human-readable message from the gateway.
  final String? message;

  /// The raw response payload from the underlying gateway, untouched.
  /// Useful for verification or audit logging on your backend.
  final Map<String, dynamic>? rawResponse;

  /// True when the payment was completed successfully.
  bool get isSuccess => this is PaymentSuccess;

  /// True when the payment was attempted but failed.
  bool get isFailure => this is PaymentFailure;

  /// True when the user cancelled before completing payment.
  bool get isCancelled => this is PaymentCancelled;
}

/// A successful payment.
final class PaymentSuccess extends PaymentResult {
  /// Create a [PaymentSuccess].
  const PaymentSuccess({
    required this.transactionId,
    super.gatewayName,
    super.message,
    super.rawResponse,
  });

  /// The gateway-side identifier you should persist and verify server-side.
  final String transactionId;

  @override
  String toString() =>
      'PaymentSuccess(gatewayName: $gatewayName, '
      'transactionId: $transactionId, message: $message)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentSuccess &&
          other.gatewayName == gatewayName &&
          other.transactionId == transactionId &&
          other.message == message;

  @override
  int get hashCode => Object.hash(gatewayName, transactionId, message);
}

/// A failed payment — gateway rejected, network failure, validation error, etc.
final class PaymentFailure extends PaymentResult {
  /// Create a [PaymentFailure].
  const PaymentFailure({
    required this.errorCode,
    required String super.message,
    super.gatewayName,
    super.rawResponse,
  });

  /// A gateway-specific error code. Stable enough to branch on.
  final String errorCode;

  @override
  String toString() =>
      'PaymentFailure(gatewayName: $gatewayName, '
      'errorCode: $errorCode, message: $message)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentFailure &&
          other.gatewayName == gatewayName &&
          other.errorCode == errorCode &&
          other.message == message;

  @override
  int get hashCode => Object.hash(gatewayName, errorCode, message);
}

/// The user dismissed the payment sheet without completing a transaction.
final class PaymentCancelled extends PaymentResult {
  /// Create a [PaymentCancelled].
  const PaymentCancelled({super.gatewayName, super.message, super.rawResponse});

  @override
  String toString() =>
      'PaymentCancelled(gatewayName: $gatewayName, message: $message)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentCancelled &&
          other.gatewayName == gatewayName &&
          other.message == message;

  @override
  int get hashCode => Object.hash(gatewayName, message);
}
