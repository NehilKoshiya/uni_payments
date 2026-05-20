import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import '../models/payment_result.dart';

const _gatewayName = 'stripe';

/// Stripe integration using the PaymentSheet API. Internal — call via
/// `UniPayments.payWithStripe(...)`.
class StripeGateway {
  /// Create a stateless [StripeGateway].
  const StripeGateway();

  /// Initialise Stripe with the supplied [publishableKey], present the
  /// PaymentSheet, and resolve once the user finishes the flow.
  Future<PaymentResult> pay({
    required String publishableKey,
    required String clientSecret,
    required String merchantDisplayName,
    String? customerId,
    String? customerEphemeralKeySecret,
    String? merchantCountryCode,
    String? applePayMerchantId,
    bool googlePayTestEnv = true,
  }) async {
    try {
      // The Stripe singleton is process-wide; re-assigning the key on each
      // call is cheap and lets us keep this entry point fully stateless.
      Stripe.publishableKey = publishableKey;
      if (applePayMerchantId != null) {
        Stripe.merchantIdentifier = applePayMerchantId;
      }
      await Stripe.instance.applySettings();

      final applePay =
          (applePayMerchantId != null && merchantCountryCode != null)
          ? PaymentSheetApplePay(merchantCountryCode: merchantCountryCode)
          : null;

      final googlePay = merchantCountryCode == null
          ? null
          : PaymentSheetGooglePay(
              merchantCountryCode: merchantCountryCode,
              testEnv: googlePayTestEnv,
            );

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: merchantDisplayName,
          customerId: customerId,
          customerEphemeralKeySecret: customerEphemeralKeySecret,
          applePay: applePay,
          googlePay: googlePay,
          style: ThemeMode.system,
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      // PaymentIntent client_secret format: `pi_<id>_secret_<token>`. Pull the
      // intent id off the front so callers have something to verify against.
      final paymentIntentId = clientSecret.split('_secret_').first;
      return PaymentSuccess(
        gatewayName: _gatewayName,
        transactionId: paymentIntentId,
        message: 'Stripe payment completed',
      );
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) {
        return PaymentCancelled(
          gatewayName: _gatewayName,
          message: e.error.localizedMessage ?? 'Payment cancelled',
        );
      }
      return PaymentFailure(
        gatewayName: _gatewayName,
        errorCode: e.error.code.name,
        message: e.error.localizedMessage ?? e.error.message ?? 'Stripe error',
      );
    } catch (e) {
      return PaymentFailure(
        gatewayName: _gatewayName,
        errorCode: 'stripe_error',
        message: e.toString(),
      );
    }
  }
}
