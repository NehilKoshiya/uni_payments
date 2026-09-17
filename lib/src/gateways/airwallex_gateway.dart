import 'package:airwallex_payment_flutter/airwallex.dart';
import 'package:airwallex_payment_flutter/types/environment.dart';
import 'package:airwallex_payment_flutter/types/payment_result.dart' as aw;
import 'package:airwallex_payment_flutter/types/payment_session.dart';

import '../models/payment_result.dart';

const _gatewayName = 'airwallex';

/// Airwallex integration via the hosted payment sheet. Internal — call via
/// `UniPayments.payWithAirwallex(...)`.
///
/// [clientSecret] and [paymentIntentId] come from a `PaymentIntent` your
/// server creates via Airwallex's API — never hard-code them.
class AirwallexGateway {
  /// Create a stateless [AirwallexGateway].
  const AirwallexGateway();

  /// Initialise the SDK and present Airwallex's full payment sheet
  /// (cards, wallets, and local redirect methods, depending on what your
  /// account supports).
  Future<PaymentResult> pay({
    required String clientSecret,
    required String paymentIntentId,
    required double amount,
    required String currency,
    required String countryCode,
    String? customerId,
    bool useStagingEnvironment = false,
  }) async {
    try {
      // The Airwallex SDK is process-wide; re-initialising on each call is
      // cheap and keeps this entry point stateless, like the Stripe gateway.
      Airwallex.initialize(
        environment: useStagingEnvironment
            ? Environment.staging
            : Environment.production,
        enableLogging: false,
      );

      final session = OneOffSession(
        clientSecret: clientSecret,
        paymentIntentId: paymentIntentId,
        amount: amount,
        currency: currency,
        countryCode: countryCode,
        customerId: customerId,
      );

      final result = await Airwallex().presentEntirePaymentFlow(session);

      return switch (result) {
        aw.PaymentSuccessResult(:final paymentConsentId) => PaymentSuccess(
          gatewayName: _gatewayName,
          transactionId: paymentIntentId,
          message: 'Airwallex payment completed',
          rawResponse: paymentConsentId == null
              ? null
              : <String, dynamic>{'paymentConsentId': paymentConsentId},
        ),
        aw.PaymentCancelledResult() => const PaymentCancelled(
          gatewayName: _gatewayName,
          message: 'User cancelled the Airwallex payment',
        ),
        // The payment was submitted but its outcome isn't known yet — the
        // same "don't treat as paid" situation as Razorpay's external
        // wallet case. Verify via your backend/webhook before fulfilling.
        aw.PaymentInProgressResult() => const PaymentFailure(
          gatewayName: _gatewayName,
          errorCode: 'payment_in_progress',
          message:
              'Airwallex payment submitted but not yet confirmed — verify '
              'via webhook before treating it as paid.',
        ),
        _ => PaymentFailure(
          gatewayName: _gatewayName,
          errorCode: 'airwallex_unknown_result',
          message: 'Unrecognised Airwallex payment result: $result',
        ),
      };
    } catch (e) {
      return PaymentFailure(
        gatewayName: _gatewayName,
        errorCode: 'airwallex_error',
        message: e.toString(),
        rawResponse: <String, dynamic>{'exception': e.toString()},
      );
    }
  }
}
