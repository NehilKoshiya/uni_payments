import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:uni_payments/uni_payments.dart';

class PayStackService {
  // declaration of payStackPlugin object
  final plugin = PaystackPlugin();

  /// [openPaystackWithCard] for initialize and manage transaction using payStackCard.
  openPaystackWithCard({
    required BuildContext context,
    required double amount,
    required String emailId,
    required String payStackKey,
  }) async {
    /// declaration of payStackKey
    String publicKey = payStackKey;

    /// initialization of payStack Plugin.
    await plugin.initialize(publicKey: publicKey);

    Charge charge = Charge()

      /// EX . if pass 200 as amount it takes 0.200,
      /// thereFore here amount multiplies with 100.
      ..amount = amount.toInt() * 100
      ..reference = _getReference()
      ..email = emailId;

    CheckoutResponse response = await plugin.checkout(
      context,
      method: CheckoutMethod.card,
      charge: charge,
    );
    return UniPaymentResponse(
      response.message.toString(),
      response.status,
      response.reference == null
          ? "Null_Payment_ID"
          : response.reference.toString(),
    );
  }

  /// for passing unique refrences, for
  String _getReference() {
    String platform;
    if (Platform.isIOS) {
      platform = 'iOS';
    } else {
      platform = 'Android';
    }
    return 'ChargedFrom${platform}_${DateTime.now().millisecondsSinceEpoch}';
  }
}
