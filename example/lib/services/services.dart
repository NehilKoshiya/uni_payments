import 'package:flutter/material.dart';
import 'package:uni_payments/methods/paystack_service.dart';
import 'package:uni_payments/uni_payments.dart';
import 'package:uni_payments_example/helpers/helpers.dart';

class Services {
  Future callRazorPayService(GlobalKey<ScaffoldState> key) async {
    await UniPayments.razorPayPayment(
      razorpayKey: "ENTER_RAZORPAY_KEY",
      contactNumber: "ENTER_MOBILE_NUMBER",
      emailId: "ENTER_EMAIL_ID",
      amount: 2500,
      userName: "ENTER_USER_NAME",
      successListener: (UniPaymentResponse uniPaymentResponse) {
        /// here manage code for success payment. ///
        if (uniPaymentResponse.paymentStatus) {
          Helpers().snackBar(key, true, "Razorpay Payment Success");
        }
      },
      failureListener: (UniPaymentResponse uniPaymentResponse) {
        /// here manage code for failure or error in payment. ///
        if (uniPaymentResponse.paymentStatus) {
          Helpers().snackBar(key, false, "Razorpay Payment Failure");
        }
      },
    );
  }

  Future callPayStackService({required BuildContext context}) async {
    /// Return UniPaymentResponse ///
    return await PayStackService().openPaystackWithCard(
      context: context,
      emailId: "ENTER_EMAIL_ID",
      payStackKey: 'ENTER_PAYSTACK_KEY_HERE',
      amount: 2500,
    );
  }

  Future callPayTmService(GlobalKey<ScaffoldState> key) async {
    await UniPayments.paytmPayment(
      baseUrl: "ENTER_BASE_URL_FROM_BACKEND",
      bodyParameter: {
        /// Enter map of bodyparameter ///
      },
      headers: {
        /// Enter map of headers ///
      },
      paytmMerchantId: "ENTER_PAYTM_MERCHENT_ID",
      orderId: "ENTER_ORDER_ID",
      isTesting: true,
      amount: 2500,
      successListener: (UniPaymentResponse uniPaymentResponse) {
        /// here manage code for success payment. ///
        if (uniPaymentResponse.paymentStatus) {
          Helpers().snackBar(key, true, "Paytm Payment Success");
        }
      },
      failureListener: (UniPaymentResponse uniPaymentResponse) {
        /// here manage code for failure or error in payment. ///
        if (uniPaymentResponse.paymentStatus) {
          Helpers().snackBar(key, false, "Paytm Payment Failure");
        }
      },
    );
  }

  Future callFlutterWaveService(
      {required BuildContext context,
      required GlobalKey<ScaffoldState> key}) async {
    await UniPayments.flutterWavePayment(
      buildContext: context,
      publicKey: 'ENTER_PUBLIC_KEY_HERE',
      encryptionKey: 'ENTER_ENCRYPTION_KEY',
      currencyCode: 'NGN',
      amount: '2500',
      receiptantName: 'ENTER_USER_NAME',
      emailId: 'ENTER_EMAIL_ID',
      phoneNumber: 'ENTER_CONTACT_NUMBER',
      isDebugMode: true,
      acceptCardPayment: true,
      successListener: (UniPaymentResponse uniPaymentResponse) {
        /// here manage code for success payment. ///
        if (uniPaymentResponse.paymentStatus) {
          Helpers().snackBar(key, true, "FlutterWave Payment Success");
        }
      },
      failureListener: (UniPaymentResponse uniPaymentResponse) {
        /// here manage code for failure or error in payment. ///
        if (uniPaymentResponse.paymentStatus) {
          Helpers().snackBar(key, false, "FlutterWave Payment Failure");
        }
      },
    );
  }
}
