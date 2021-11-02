import 'package:flutter/material.dart';

import 'package:uni_payments/methods/flutterwave_service.dart';
import 'package:uni_payments/methods/paystack_service.dart';
import 'package:uni_payments/methods/paytm_service.dart';
import 'package:uni_payments/methods/razorpay_service.dart';
import 'package:uni_payments/model/unipaymentresponse.dart';

export '../../model/unipaymentresponse.dart';

/// Main class where all methods are called and return perticular response
class UniPayments {
  /// [razorPayPayment] is called,to integrate RazorpayPayment gateway.
  /// All parameters are [contactNumber], [emailId], [razorpayKey], [amount] and [userName] must be non-null.
  /// [successListener] and [failureListener] are for listening events for managing methods.
  static razorPayPayment({
    required String contactNumber,
    required String emailId,
    required String razorpayKey,
    required double amount,
    required String userName,
    required Function(UniPaymentResponse) successListener,
    required Function(UniPaymentResponse) failureListener,
  }) {
    return RazorpayServices().openRazorpay(
        contactNumber: contactNumber,
        emailId: emailId,
        razorpayKey: razorpayKey,
        amount: amount,
        userName: userName,
        successListener: successListener,
        failureListener: failureListener);
  }

  /// [payStackPaymentWithCard] is called,to integrate PayStackPayment gateway.
  /// Following parameters are [context], [emailId], [amount], and [payStackKey] must be non-null.
  /// [payStackKey] get from the official site of PAYSTACK which is mentaioned below.
  /// <https://paystack.com/>.
  static payStackPaymentWithCard({
    required BuildContext context,
    required double amount,
    required String emailId,
    required String payStackKey,
  }) {
    return PayStackService().openPaystackWithCard(
        context: context,
        amount: amount,
        emailId: emailId,
        payStackKey: payStackKey);
  }

  /// [paytmPayment] is called,to integrate PayStackPayment gateway.
  /// Following parameters are [paytmMerchantId], [orderId], and [amount] must be non-null.
  /// [baseUrl], [bodyParameter] and [headers] are passed releated to your backend URL.
  /// [paytmMerchantId] get from the official site of paytm which is mentaioned below.
  /// [isTesting], if using testing key then pass [true] otherwise [false].
  /// <https://developer.paytm.com/>.
  static paytmPayment({
    required String baseUrl,
    required Map<String, String> bodyParameter,
    required Map<String, String> headers,
    required String paytmMerchantId,
    required String orderId,
    required bool isTesting,
    required double amount,
    required Function(UniPaymentResponse) successListener,
    required Function(UniPaymentResponse) failureListener,
  }) {
    return PaytmService().openPaytm(
        baseUrl: baseUrl,
        body: bodyParameter,
        headers: headers,
        paytmMerchantId: paytmMerchantId,
        orderId: orderId,
        isTesting: isTesting,
        amount: amount,
        successListener: successListener,
        failureListener: failureListener);
  }

  /// [flutterWavePayment] is called,to integrate PayStackPayment gateway.
  /// Following parameters are [buildContext], [encryptionKey],[publicKey],[currencyCode],[amount],[emailId],
  /// [receiptantName],[phoneNumber],and [isDebugMode]  must be non-null.
  /// rest of are not neccesary as per need.
  /// <https://flutterwave.com/us/>.
  static flutterWavePayment({
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
  }) {
    return FlutterWaveService().openFlutterWave(
        buildContext: buildContext,
        encryptionKey: encryptionKey,
        publicKey: publicKey,
        currencyCode: currencyCode,
        amount: amount,
        emailId: emailId,
        receiptantName: receiptantName,
        phoneNumber: phoneNumber,
        isDebugMode: isDebugMode,
        successListener: successListener,
        failureListener: failureListener);
  }
}
