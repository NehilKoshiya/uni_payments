import 'package:flutter/material.dart';
import 'package:flutterwave/core/flutterwave.dart';
import 'package:flutterwave/models/responses/charge_response.dart';
import 'package:flutterwave/utils/flutterwave_constants.dart';
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
    required bool isDebugMode,
    required Function(UniPaymentResponse) successListener,
    required Function(UniPaymentResponse) failureListener,
    bool? acceptBankTransfer,
    bool? acceptCardPayment,
    bool? acceptAccountPayment,
    bool? acceptUSSDPayment,
    bool? acceptFrancophoneMobileMoney,
    bool? acceptGhanaPayment,
    bool? acceptMpesaPayment,
    bool? acceptRwandaMoneyPayment,
    bool? acceptUgandaPayment,
    bool? acceptZambiaPayment,
  }) async {
    final Flutterwave flutterwave = Flutterwave.forUIPayment(
        context: buildContext,
        encryptionKey: encryptionKey,
        publicKey: publicKey,
        currency: currencyCode,
        amount: amount,
        email: emailId,
        fullName: receiptantName,
        txRef: "tx_ref_demo",
        isDebugMode: isDebugMode,
        isPermanent: true,
        phoneNumber: phoneNumber,
        acceptBankTransfer:
            acceptBankTransfer == null ? true : acceptBankTransfer,
        acceptCardPayment: true,
        acceptAccountPayment:
            acceptAccountPayment == null ? true : acceptAccountPayment,
        acceptUSSDPayment:
            acceptAccountPayment == null ? true : acceptAccountPayment,
        acceptFrancophoneMobileMoney: acceptFrancophoneMobileMoney == null
            ? true
            : acceptFrancophoneMobileMoney,
        acceptGhanaPayment:
            acceptGhanaPayment == null ? true : acceptGhanaPayment,
        acceptMpesaPayment:
            acceptMpesaPayment == null ? true : acceptMpesaPayment,
        acceptRwandaMoneyPayment:
            acceptRwandaMoneyPayment == null ? true : acceptRwandaMoneyPayment,
        acceptUgandaPayment:
            acceptUgandaPayment == null ? true : acceptUgandaPayment,
        acceptZambiaPayment:
            acceptZambiaPayment == null ? true : acceptZambiaPayment);

    /// [checkPaymentIsSuccessful] returning bool value for payment successful or not.
    bool checkPaymentIsSuccessful(final ChargeResponse response) {
      return response.data!.status == FlutterwaveConstants.SUCCESSFUL &&
          response.data!.currency == currencyCode &&
          response.data!.amount == amount &&
          response.data!.txRef == "tx_ref_demo";
    }

    try {
      /// initialize FlutterWave object.
      ChargeResponse response = await flutterwave.initializeForUiPayments();
      if (response == null) {
        failureListener(UniPaymentResponse(
            "response called on null", false, "something went wrong"));
      } else {
        final isSuccessful = checkPaymentIsSuccessful(response);
        if (isSuccessful) {
          /// after completing successful payment,return this listeners
          successListener(
            UniPaymentResponse(response.message.toString(), true,
                response.data!.id.toString()),
          );
        } else {
          /// after getting some error or failure during transaction,return this listeners
          failureListener(UniPaymentResponse(
              response.message.toString(), false, "something went wrong!"));
        }
      }
    } catch (error) {
      /// after getting some error or failure during transaction,return this listeners
      failureListener(
          UniPaymentResponse(error.toString(), false, "something went wrong!"));
    }
  }
}
