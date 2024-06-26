import 'package:flutter/material.dart';

import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:uni_payments/model/unipaymentresponse.dart';

class RazorpayServices {
  /// RazorPay object declaration
  Razorpay? _razorpay = Razorpay();

  /// Registers event listeners for payment success events
  onSuccess(PaymentSuccessResponse response, successListener) {
    successListener(
      UniPaymentResponse(
        "Payment Successful",
        true,
        response.paymentId.toString(),
      ),
    );
  }

  /// Registers event listeners for payment failures events
  onFailure(PaymentFailureResponse response, failureLitener) {
    failureLitener(UniPaymentResponse(
        response.error!['description'], false, response.error!['reason']));
  }

  /// Method for open razorpay and listening payment events
  openRazorpay({
    required String contactNumber,
    required String emailId,
    required String razorpayKey,
    required double amount,
    required String userName,
    String? description,
    String? colorCode,
    required Function(UniPaymentResponse) successListener,
    required Function(UniPaymentResponse) failureListener,
  }) {
    Map<String, Object> options = {
      'key': razorpayKey,
      'amount': amount * 100,
      'name': userName,
      'prefill': {'contact': contactNumber, 'email': emailId},
      'description': description ?? '',
      'theme': {
        'color': colorCode ?? '#0CA72F',
      },
      'send_sms_hash': true,
    };
    try {
      /// event listeners for successs payment
      _razorpay!.on(
        Razorpay.EVENT_PAYMENT_SUCCESS,
        (res) {
          onSuccess(res, successListener);
        },
      );

      /// event listeners for failure payment
      _razorpay!.on(
        Razorpay.EVENT_PAYMENT_ERROR,
        (res) {
          onFailure(res, failureListener);
        },
      );

      /// initialize razrorpay
      _razorpay!.open(options);
    } catch (e) {
      /// return if something went wrong
      debugPrint(
        failureListener(
          UniPaymentResponse(
            e.toString(),
            false,
            "Something went wrong!",
          ),
        ),
      );
    }
  }
}
