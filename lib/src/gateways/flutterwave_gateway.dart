import 'package:flutter/material.dart';
import 'package:flutterwave_standard/flutterwave.dart';

import '../models/payment_result.dart';
import '../models/uni_customer.dart';

const _gatewayName = 'flutterwave';

/// Flutterwave integration. Internal — call via
/// `UniPayments.payWithFlutterwave(...)`.
class FlutterwaveGateway {
  /// Create a stateless [FlutterwaveGateway].
  const FlutterwaveGateway();

  /// Open the Flutterwave standard checkout.
  ///
  /// `flutterwave_standard` only needs your **public** key — the encryption
  /// step happens server-side, on Flutterwave's hosted modal. Do not pass
  /// secret/encryption keys here.
  Future<PaymentResult> pay({
    required BuildContext context,
    required String publicKey,
    required String currency,
    required double amount,
    required UniCustomer customer,
    required String txRef,
    required String redirectUrl,
    required bool testMode,
    required String paymentOptions,
  }) async {
    try {
      final fwCustomer = Customer(
        name: customer.name,
        phoneNumber: customer.phone ?? '',
        email: customer.email,
      );

      final flutterwave = Flutterwave(
        publicKey: publicKey,
        currency: currency,
        redirectUrl: redirectUrl,
        txRef: txRef,
        amount: amount.toStringAsFixed(2),
        customer: fwCustomer,
        paymentOptions: paymentOptions,
        isTestMode: testMode,
        customization: Customization(title: customer.name),
      );

      if (!context.mounted) {
        return const PaymentFailure(
          gatewayName: _gatewayName,
          errorCode: 'flutterwave_context_unmounted',
          message: 'BuildContext was unmounted before showing the modal',
        );
      }

      final response = await flutterwave.charge(context);
      final raw = response.toJson();
      final success = (raw['success'] as bool?) ?? false;
      final status = raw['status']?.toString() ?? '';
      final txnId = raw['transaction_id']?.toString() ?? '';
      final normalisedRaw = Map<String, dynamic>.from(raw);

      if (success) {
        return PaymentSuccess(
          gatewayName: _gatewayName,
          transactionId: txnId,
          message: 'Status: $status, Ref: ${raw['tx_ref']}',
          rawResponse: normalisedRaw,
        );
      }

      if (status.toLowerCase() == 'cancelled') {
        return PaymentCancelled(
          gatewayName: _gatewayName,
          message: 'User cancelled the Flutterwave payment',
          rawResponse: normalisedRaw,
        );
      }

      return PaymentFailure(
        gatewayName: _gatewayName,
        errorCode: status.isNotEmpty ? status : 'flutterwave_failed',
        message: 'Status: $status, Ref: ${raw['tx_ref']}',
        rawResponse: normalisedRaw,
      );
    } catch (e) {
      return PaymentFailure(
        gatewayName: _gatewayName,
        errorCode: 'flutterwave_error',
        message: e.toString(),
      );
    }
  }
}
