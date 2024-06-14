import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:uni_payments/uni_payments.dart';

class Services {
  Future callRazorPayService() async {
    await UniPayments.razorPayPayment(
      razorpayKey: "enter_key_here",
      contactNumber: "+91-1234567890",
      emailId: "test@gmail.com",
      amount: 2500,
      userName: "uni_payments",
      colorCode: '#fcba03',
      description: 'Add the description for the order or payment.',
      successListener: (UniPaymentResponse uniPaymentResponse) {
        /// here manage code for success payment.
        bool isSuccessPayment = uniPaymentResponse.paymentStatus;
        if (isSuccessPayment) {
          log(uniPaymentResponse.message);
          log(uniPaymentResponse.paymentId);
        }
      },
      failureListener: (UniPaymentResponse uniPaymentResponse) {
        /// here manage code for failure or error in payment.
        bool isFailedPayment = uniPaymentResponse.paymentStatus;
        if (isFailedPayment) {
          log(uniPaymentResponse.message);
          log(uniPaymentResponse.paymentId);
        }
      },
    );
  }

  Future payStackService({required BuildContext context}) async {
    /// Return UniPaymentResponse ///
    UniPaymentResponse uniPaymentResponse = await UniPayments.payStackPayment(
      context: context,
      emailId: "test@gmail.com",
      payStackKey: 'enter_key_here',
      amount: 2500,
      uniqueRefrenceID: 'XfhjsgpG87ds50mf',
      callbackUrl: 'https://meta-labs-website.web.app/',
    );

    bool isSuccessPayment = uniPaymentResponse.paymentStatus;

    if (isSuccessPayment) {
      log(uniPaymentResponse.message);
      log(uniPaymentResponse.paymentId);
    } else {
      log(uniPaymentResponse.message);
      log(uniPaymentResponse.paymentId);
    }
  }

  Future paytmService() async {
    await UniPayments.paytmPayment(
      /// Login to "dashboard.paytm.com" with your Paytm account details & Get Merchant Id.
      paytmMerchantId: "paytm_merchant_id",
      orderId: "order_id",
      isStaging: true,
      uniqueTransactionToken: "unique_id_database_refrences",
      amount: 2500,
      successListener: (UniPaymentResponse uniPaymentResponse) {
        /// here manage code for success payment.
        bool isSuccessPayment = uniPaymentResponse.paymentStatus;
        if (isSuccessPayment) {
          log(uniPaymentResponse.message);
          log(uniPaymentResponse.paymentId);
        }
      },
      failureListener: (UniPaymentResponse uniPaymentResponse) {
        /// here manage code for failure or error in payment.
        bool isFailedPayment = uniPaymentResponse.paymentStatus;
        if (isFailedPayment) {
          log(uniPaymentResponse.message);
          log(uniPaymentResponse.paymentId);
        }
      },
    );
  }

  Future flutterWaveService({required BuildContext context}) async {
    await UniPayments.flutterWavePayment(
      buildContext: context,
      publicKey: 'enter_public_key_here',
      encryptionKey: 'enter_encryprion_key',
      currencyCode: 'NGN',
      amount: '2500',
      receiptantName: 'Test User',
      emailId: 'test@gmail.com',
      phoneNumber: '+91-1234567890',
      isDebugMode: true,
      redirectURL: 'add-redirect-url-here',
      transactionRef: 'add-random-string-everytime-transaction-refrence',
      successListener: (UniPaymentResponse uniPaymentResponse) {
        /// here manage code for success payment.
        bool isSuccessPayment = uniPaymentResponse.paymentStatus;
        if (isSuccessPayment) {
          log(uniPaymentResponse.message);
          log(uniPaymentResponse.paymentId);
        }
      },
      failureListener: (UniPaymentResponse uniPaymentResponse) {
        /// here manage code for failure or error in payment.
        bool isFailedPayment = uniPaymentResponse.paymentStatus;
        if (isFailedPayment) {
          log(uniPaymentResponse.message);
          log(uniPaymentResponse.paymentId);
        }
      },
    );
  }

  Future callBraintreePaypalService() async {
    UniPaymentResponse uniPaymentResponse =
        await UniPayments.payPalBraintreePayment(
            tokenizationKey: "enter_key_here",
            amount: 5200,
            emailId: 'test@gmail.com',
            name: 'Nehil',
            countryCode: 'US',
            currencyCode: 'USD');

    bool isSuccessPayment = uniPaymentResponse.paymentStatus;
    if (isSuccessPayment) {
      log(uniPaymentResponse.message);
      log(uniPaymentResponse.paymentId);
    } else {
      log(uniPaymentResponse.message);
      log(uniPaymentResponse.paymentId);
    }
  }
}
