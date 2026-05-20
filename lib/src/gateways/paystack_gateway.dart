import 'package:flutter/material.dart';
import 'package:flutter_paystack_max/flutter_paystack_max.dart';

import '../models/payment_result.dart';
import '../models/uni_customer.dart';

const _gatewayName = 'paystack';

/// Subset of Paystack-supported currencies, mirrored here so consumers
/// don't have to import the upstream package directly.
enum UniPaystackCurrency {
  /// United States Dollar.
  usd,

  /// Nigerian Naira.
  ngn,

  /// Ghanaian Cedi.
  ghs,

  /// South African Rand.
  zar,

  /// Kenyan Shilling.
  kes,
}

extension on UniPaystackCurrency {
  PaystackCurrency get upstream => switch (this) {
    UniPaystackCurrency.usd => PaystackCurrency.usd,
    UniPaystackCurrency.ngn => PaystackCurrency.ngn,
    UniPaystackCurrency.ghs => PaystackCurrency.ghs,
    UniPaystackCurrency.zar => PaystackCurrency.zar,
    UniPaystackCurrency.kes => PaystackCurrency.kes,
  };
}

/// Paystack integration. Internal — call via
/// `UniPayments.payWithPaystack(...)`.
class PaystackGateway {
  /// Create a stateless [PaystackGateway].
  const PaystackGateway();

  /// Initialise a Paystack transaction, present the payment modal, and
  /// then verify the transaction server-side via Paystack.
  Future<PaymentResult> pay({
    required BuildContext context,
    required String secretKey,
    required double amount,
    required UniCustomer customer,
    required String reference,
    required String callbackUrl,
    required UniPaystackCurrency currency,
  }) async {
    try {
      final request = PaystackTransactionRequest(
        reference: reference,
        secretKey: secretKey,
        email: customer.email,
        amount: amount * 100,
        currency: currency.upstream,
        channel: const [
          PaystackPaymentChannel.mobileMoney,
          PaystackPaymentChannel.card,
          PaystackPaymentChannel.ussd,
          PaystackPaymentChannel.bankTransfer,
          PaystackPaymentChannel.bank,
          PaystackPaymentChannel.qr,
          PaystackPaymentChannel.eft,
        ],
      );

      final initialized = await PaymentService.initializeTransaction(request);

      if (!initialized.status) {
        return PaymentFailure(
          gatewayName: _gatewayName,
          errorCode: 'paystack_init_failed',
          message: initialized.message,
        );
      }

      if (!context.mounted) {
        return const PaymentFailure(
          gatewayName: _gatewayName,
          errorCode: 'paystack_context_unmounted',
          message: 'BuildContext was unmounted before showing the modal',
        );
      }

      await PaymentService.showPaymentModal(
        context,
        transaction: initialized,
        callbackUrl: callbackUrl,
      );

      final verified = await PaymentService.verifyTransaction(
        paystackSecretKey: secretKey,
        initialized.data?.reference ?? request.reference,
      );

      final txnId = verified.data.id.toString();
      return switch (verified.data.status) {
        PaystackTransactionStatus.success => PaymentSuccess(
          gatewayName: _gatewayName,
          transactionId: txnId,
          message: verified.message,
        ),
        PaystackTransactionStatus.abandoned => PaymentCancelled(
          gatewayName: _gatewayName,
          message: verified.message,
        ),
        _ => PaymentFailure(
          gatewayName: _gatewayName,
          errorCode: verified.data.status.toString(),
          message: verified.message,
        ),
      };
    } catch (e) {
      return PaymentFailure(
        gatewayName: _gatewayName,
        errorCode: 'paystack_error',
        message: e.toString(),
      );
    }
  }
}
