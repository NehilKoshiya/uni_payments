import 'package:flutter/material.dart';
import 'package:flutter_paystack_max/flutter_paystack_max.dart';
import 'package:uni_payments/uni_payments.dart';

class PaystackService {
  openPaystack({
    required BuildContext context,
    required String uniqueRefrenceID,
    required String callbackUrl,
    required double amount,
    required String emailId,
    required String payStackKey,
  }) async {
    try {
      final request = PaystackTransactionRequest(
        reference: uniqueRefrenceID,
        secretKey: payStackKey,
        email: emailId,
        amount: amount * 100,
        currency: PaystackCurrency.usd,
        channel: [
          PaystackPaymentChannel.mobileMoney,
          PaystackPaymentChannel.card,
          PaystackPaymentChannel.ussd,
          PaystackPaymentChannel.bankTransfer,
          PaystackPaymentChannel.bank,
          PaystackPaymentChannel.qr,
          PaystackPaymentChannel.eft,
        ],
      );

      print(request.secretKey);

      /// initialized paystack transaction
      final initializedTransaction =
          await PaymentService.initializeTransaction(request);

      if (!initializedTransaction.status) {
        /// Response for payment failures events
        return UniPaymentResponse(
          initializedTransaction.message,
          false,
          initializedTransaction.data!.reference.toString(),
        );
      }

      await PaymentService.showPaymentModal(
        context,
        transaction: initializedTransaction,
        callbackUrl: callbackUrl,
      );

      PaystackTransactionVerified payStackData =
          await PaymentService.verifyTransaction(
        paystackSecretKey: payStackKey,
        initializedTransaction.data?.reference ?? request.reference,
      );

      if (payStackData.data.status == PaystackTransactionStatus.success) {
        return UniPaymentResponse(
          "${payStackData.data.status}-${payStackData.message}",
          true,
          payStackData.data.id.toString(),
        );
      } else {
        /// Return response for payment failures events
        return UniPaymentResponse(
          "${payStackData.data.status}-${payStackData.message}",
          false,
          payStackData.data.id.toString(),
        );
      }
    } catch (e) {
      /// Return response for payment failures events
      return UniPaymentResponse(
        e.toString(),
        false,
        "Payment_Failed",
      );
    }
  }
}
