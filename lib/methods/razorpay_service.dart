import 'dart:convert';
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
        "successful response",
        true,
        response.paymentId.toString(),
      ),
    );
  }

  /// Registers event listeners for payment failures events
  onFailure(PaymentFailureResponse response, failureLitener) {
    failureLitener(UniPaymentResponse(
        json.decode(response.message!)['error']['description'],
        false,
        json.decode(response.message!)['error']['reason']));
  }

  /// Method for open razorpay and listening payment events
  openRazorpay({
    required String contactNumber,
    required String emailId,
    required String razorpayKey,
    required double amount,
    required String userName,
    required Function(UniPaymentResponse) successListener,
    required Function(UniPaymentResponse) failureListener,
  }) {
    Map<String, Object> options = {
      'key': razorpayKey,
      'amount': amount * 100,
      'name': userName,
      'prefill': {'contact': contactNumber, 'email': emailId},
    };
    try {
      /// initialize razrorpay
      _razorpay!.open(options);

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
