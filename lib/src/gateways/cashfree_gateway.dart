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

  /// Present Cashfree's web checkout for a previously-created payment
  /// session.
  Future<PaymentResult> pay({
    required String orderId,
    required String paymentSessionId,
    required bool useStagingEnvironment,
  }) {
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
        ),
      );
    }

    return completer.future;
  }
}
