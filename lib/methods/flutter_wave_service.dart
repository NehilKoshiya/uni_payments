import 'package:flutter/material.dart';
import 'package:flutterwave_standard/flutterwave.dart';
import '../uni_payments.dart';

class FlutterWaveService {
  openFlutterWave({
    required BuildContext buildContext,
    required String encryptionKey,
    required String publicKey,
    required String currencyCode,
    required String amount,
    required String emailId,
    required String receiptantName,
    required String phoneNumber,
    required String redirectURL,
    required String transactionRef,
    required bool isDebugMode,
    required Function(UniPaymentResponse) successListener,
    required Function(UniPaymentResponse) failureListener,
  }) async {
    try {
      /// Customer object for storing initial details of payer
      final Customer customer = Customer(
          name: receiptantName, phoneNumber: phoneNumber, email: emailId);

      /// Flutter wave object with init transaction details
      final Flutterwave flutterwave = Flutterwave(
        context: buildContext,
        publicKey: publicKey,
        currency: currencyCode,
        redirectUrl: redirectURL,
        txRef: transactionRef,
        amount: amount.toString(),
        customer: customer,
        paymentOptions: "ussd, card, barter, payattitude",
        isTestMode: isDebugMode,
        customization: Customization(),
      );

      final ChargeResponse response = await flutterwave.charge();

      if (response.toJson()['success']) {
        /// Registers event listeners for payment success events
        successListener(
          UniPaymentResponse(
              "Status : ${response.toJson()['status'].toString()}, Transaction Refrence : ${response.toJson()['tx_ref'].toString()}",
              response.toJson()['success'],
              response.toJson()['transaction_id'].toString()),
        );
      } else {
        /// Registers event listeners for payment failures events
        failureListener(UniPaymentResponse(
            "Status : ${response.toJson()['status'].toString()}, Transaction Refrence : ${response.toJson()['tx_ref'].toString()}",
            response.toJson()['success'],
            response.toJson()['transaction_id'].toString()));
      }
    } catch (e) {
      /// Registers event listeners for payment failures events
      failureListener(
          UniPaymentResponse(e.toString(), false, "something went wrong!"));
    }
  }
}
