import 'dart:async';

import 'package:flutter_cashfree_pg_sdk/api/cferrorresponse/cferrorresponse.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfwebcheckoutpayment.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpaymentgateway/cfpaymentgatewayservice.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfsession/cfsession.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfenums.dart';

import '../models/payment_result.dart';

const _gatewayName = 'cashfree';

/// Cashfree (India) integration. Internal — call via
/// `UniPayments.payWithCashfree(...)`.
///
/// Cashfree's checkout is server-driven: your backend creates an order,
/// which yields a `paymentSessionId`. You hand that here, present the
/// hosted web checkout, and Cashfree fires our callback when the user
/// completes or errors out.
class CashfreeGateway {
  /// Create a stateless [CashfreeGateway].
  const CashfreeGateway();

  // `CFPaymentGatewayService` is a process-wide singleton with *static*
  // callback fields (not per-instance) — a second `pay()` call started
  // before the first resolves would silently overwrite the first call's
  // callbacks, leaving it hanging forever. Guard against that here since
  // the upstream SDK doesn't.
  static bool _paymentInProgress = false;

  /// Present Cashfree's web checkout for a previously-created payment
  /// session.
  ///
  /// Only one Cashfree payment may be in flight at a time (an upstream SDK
  /// limitation — see [_paymentInProgress]); a call made while another is
  /// still pending resolves immediately with a [PaymentFailure].
  ///
  /// Pass [timeout] to bound how long this waits for Cashfree's callback
  /// before giving up with a [PaymentFailure]; by default it waits
  /// indefinitely, matching prior behaviour.
  Future<PaymentResult> pay({
    required String orderId,
    required String paymentSessionId,
    required bool useStagingEnvironment,
    Duration? timeout,
  }) {
    if (_paymentInProgress) {
      return Future<PaymentResult>.value(
        const PaymentFailure(
          gatewayName: _gatewayName,
          errorCode: 'cashfree_already_in_progress',
          message:
              'A Cashfree payment is already in progress. Wait for it to '
              'finish before starting another.',
        ),
      );
    }
    _paymentInProgress = true;

    final completer = Completer<PaymentResult>();
    final service = CFPaymentGatewayService();

    void resolve(PaymentResult result) {
      if (!completer.isCompleted) completer.complete(result);
    }

    service.setCallback(
      (returnedOrderId) {
        // Success path — `returnedOrderId` should match `orderId`.
        resolve(
          PaymentSuccess(
            gatewayName: _gatewayName,
            transactionId: returnedOrderId,
            message: 'Cashfree payment completed',
          ),
        );
      },
      (CFErrorResponse error, returnedOrderId) {
        final status = error.getStatus()?.toUpperCase() ?? '';
        final message = error.getMessage() ?? 'Cashfree payment failed';

        // Cashfree marks user-driven exits with status "CANCELLED" or with
        // codes like "payment_cancelled" — collapse to PaymentCancelled so
        // consumers don't have to special-case it.
        final isCancel =
            status == 'CANCELLED' ||
            (error.getCode()?.toLowerCase().contains('cancel') ?? false);

        if (isCancel) {
          resolve(
            PaymentCancelled(
              gatewayName: _gatewayName,
              message: message,
              rawResponse: <String, dynamic>{
                'orderId': returnedOrderId,
                'status': error.getStatus(),
                'code': error.getCode(),
                'type': error.getType(),
              },
            ),
          );
        } else {
          resolve(
            PaymentFailure(
              gatewayName: _gatewayName,
              errorCode: error.getCode() ?? 'cashfree_failed',
              message: message,
              rawResponse: <String, dynamic>{
                'orderId': returnedOrderId,
                'status': error.getStatus(),
                'type': error.getType(),
              },
            ),
          );
        }
      },
    );

    try {
      final session = CFSessionBuilder()
          .setEnvironment(
            useStagingEnvironment
                ? CFEnvironment.SANDBOX
                : CFEnvironment.PRODUCTION,
          )
          .setOrderId(orderId)
          .setPaymentSessionId(paymentSessionId)
          .build();

      final payment = CFWebCheckoutPaymentBuilder().setSession(session).build();

      service.doPayment(payment);
    } catch (e) {
      resolve(
        PaymentFailure(
          gatewayName: _gatewayName,
          errorCode: 'cashfree_init_error',
          message: e.toString(),
          rawResponse: <String, dynamic>{'exception': e.toString()},
        ),
      );
    }

    var future = completer.future;
    if (timeout != null) {
      future = future.timeout(
        timeout,
        onTimeout: () => PaymentFailure(
          gatewayName: _gatewayName,
          errorCode: 'cashfree_timeout',
          message: 'No response from Cashfree within $timeout',
        ),
      );
    }
    return future.whenComplete(() => _paymentInProgress = false);
  }
}
