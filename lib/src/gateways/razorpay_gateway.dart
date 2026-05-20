import 'dart:async';

import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../models/payment_result.dart';
import '../models/uni_customer.dart';

const _gatewayName = 'razorpay';

/// Razorpay integration. Internal — consumers should call
/// `UniPayments.payWithRazorpay(...)`.
class RazorpayGateway {
  /// Create a stateless [RazorpayGateway].
  const RazorpayGateway();

  /// Open the Razorpay checkout sheet and resolve when the user completes,
  /// cancels, or hits an error.
  Future<PaymentResult> pay({
    required String keyId,
    required double amount,
    required String businessName,
    required UniCustomer customer,
    required String description,
    required String currency,
    Color? themeColor,
  }) {
    final completer = Completer<PaymentResult>();
    final razorpay = Razorpay();

    void resolve(PaymentResult result) {
      if (!completer.isCompleted) completer.complete(result);
    }

    razorpay
      ..on(Razorpay.EVENT_PAYMENT_SUCCESS, (PaymentSuccessResponse response) {
        resolve(
          PaymentSuccess(
            gatewayName: _gatewayName,
            transactionId: response.paymentId ?? '',
            message: 'Payment successful',
            rawResponse: <String, dynamic>{
              'orderId': response.orderId,
              'signature': response.signature,
            },
          ),
        );
      })
      ..on(Razorpay.EVENT_PAYMENT_ERROR, (PaymentFailureResponse response) {
        if (response.code == Razorpay.PAYMENT_CANCELLED) {
          resolve(
            PaymentCancelled(
              gatewayName: _gatewayName,
              message: response.message ?? 'Payment cancelled',
            ),
          );
        } else {
          resolve(
            PaymentFailure(
              gatewayName: _gatewayName,
              errorCode: '${response.code}',
              message: response.message ?? 'Payment failed',
              rawResponse: response.error?.cast<String, dynamic>(),
            ),
          );
        }
      })
      ..on(Razorpay.EVENT_EXTERNAL_WALLET, (ExternalWalletResponse response) {
        // The user picked an external wallet (e.g. PayUMoney). The actual
        // transaction completes asynchronously inside that wallet — verify
        // server-side via Razorpay's webhook before treating it as paid.
        resolve(
          PaymentFailure(
            gatewayName: _gatewayName,
            errorCode: 'external_wallet_pending',
            message:
                'Redirected to ${response.walletName ?? "external wallet"} '
                '— verify completion via webhook.',
          ),
        );
      });

    try {
      razorpay.open(<String, dynamic>{
        'key': keyId,
        'amount': (amount * 100).round(),
        'name': businessName,
        'currency': currency,
        'description': description,
        'prefill': <String, String>{
          if (customer.phone != null) 'contact': customer.phone!,
          'email': customer.email,
          'name': customer.name,
        },
        'theme': <String, String>{
          'color': _toRazorpayHex(themeColor ?? const Color(0xFF0CA72F)),
        },
        'send_sms_hash': true,
      });
    } catch (e) {
      resolve(
        PaymentFailure(
          gatewayName: _gatewayName,
          errorCode: 'razorpay_init_error',
          message: e.toString(),
        ),
      );
    }

    return completer.future.whenComplete(razorpay.clear);
  }

  /// Razorpay expects a `#RRGGBB` string — drop the alpha channel and
  /// uppercase to match Razorpay's documented format.
  String _toRazorpayHex(Color color) {
    final argb = color.toARGB32() & 0x00FFFFFF;
    return '#${argb.toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }
}
