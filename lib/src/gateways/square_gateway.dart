import 'dart:async';

import 'package:square_in_app_payments/in_app_payments.dart';
import 'package:square_in_app_payments/models.dart' show CardDetails;

import '../models/payment_result.dart';

const _gatewayName = 'square';

/// Square integration via the native In-App Payments card-entry flow.
/// Internal — call via `UniPayments.payWithSquare(...)`.
///
/// This only tokenizes a card into a one-time-use nonce — Square's mobile
/// SDK does not charge cards itself. Send [PaymentSuccess.transactionId]
/// (the nonce) to your backend and charge it via Square's Payments API:
/// https://developer.squareup.com/docs/payments-api/take-payments.
///
/// Sandbox vs. production is determined entirely by which [applicationId]
/// you pass (sandbox app IDs look like `sandbox-sq0idb-...`) — there is no
/// separate staging flag.
class SquareGateway {
  /// Create a stateless [SquareGateway].
  const SquareGateway();

  /// Present Square's native card-entry sheet and resolve once the user
  /// completes or cancels.
  Future<PaymentResult> pay({
    required String applicationId,
    required bool collectPostalCode,
  }) async {
    final completer = Completer<PaymentResult>();

    void resolve(PaymentResult result) {
      if (!completer.isCompleted) completer.complete(result);
    }

    try {
      await InAppPayments.setSquareApplicationId(applicationId);

      await InAppPayments.startCardEntryFlow(
        collectPostalCode: collectPostalCode,
        onCardEntryCancel: () {
          resolve(
            const PaymentCancelled(
              gatewayName: _gatewayName,
              message: 'User dismissed the Square card entry sheet',
            ),
          );
        },
        onCardNonceRequestSuccess: (CardDetails result) async {
          // Acknowledge the sheet so it dismisses with a success animation.
          // We can't charge the nonce ourselves — that happens on the
          // caller's backend — so there's nothing to wait on here.
          unawaited(
            InAppPayments.completeCardEntry(onCardEntryComplete: () {}),
          );
          resolve(
            PaymentSuccess(
              gatewayName: _gatewayName,
              transactionId: result.nonce,
              message: 'Square card nonce received',
              rawResponse: <String, dynamic>{
                'nonce': result.nonce,
                'cardBrand': result.card.brand.name,
                'lastFourDigits': result.card.lastFourDigits,
                'expirationMonth': result.card.expirationMonth,
                'expirationYear': result.card.expirationYear,
              },
            ),
          );
        },
      );
    } catch (e) {
      resolve(
        PaymentFailure(
          gatewayName: _gatewayName,
          errorCode: 'square_error',
          message: e.toString(),
          rawResponse: <String, dynamic>{'exception': e.toString()},
        ),
      );
    }

    return completer.future;
  }
}
