import 'package:flutter/material.dart';
import 'package:uni_payments/methods/paypal_braintree_service.dart';

import 'package:uni_payments/methods/paystack_main_service.dart';
import 'package:uni_payments/methods/paytm_service.dart';
import 'package:uni_payments/methods/razorpay_service.dart';
import 'package:uni_payments/model/unipaymentresponse.dart';
import 'package:uni_payments/methods/googlepay_service.dart';

import 'methods/flutter_wave_service.dart';

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
    String? description,
    String? colorCode,
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
        failureListener: failureListener,
        colorCode: colorCode,
        description: description);
  }

  /// [payStackPayment] is called,to integrate PayStackPayment gateway.
  /// Following parameters are [context], [emailId], [amount], and [payStackKey] must be non-null.
  /// [payStackKey] get from the official site of PAYSTACK which is mentaioned below.
  /// <https://paystack.com/>.
  static payStackPayment({
    required BuildContext context,
    required double amount,
    required String uniqueRefrenceID,
    required String callbackUrl,
    required String emailId,
    required String payStackKey,
  }) {
    return PaystackService().openPaystack(
        context: context,
        amount: amount,
        emailId: emailId,
        payStackKey: payStackKey,
        uniqueRefrenceID: uniqueRefrenceID,
        callbackUrl: callbackUrl);
  }

  /// [paytmPayment] is called,to integrate PayStackPayment gateway.
  /// Following parameters are [paytmMerchantId], [orderId], and [amount] must be non-null.
  /// [paytmMerchantId] get from the official site of paytm which is mentaioned below.
  /// <https://developer.paytm.com/>.
  static paytmPayment({
    required String paytmMerchantId,
    required String orderId,
    required String uniqueTransactionToken,
    required bool isStaging,
    required double amount,
    required Function(UniPaymentResponse) successListener,
    required Function(UniPaymentResponse) failureListener,
  }) {
    return PaytmService().openPaytm(
        isStaging: isStaging,
        uniqueTransactionToken: uniqueTransactionToken,
        paytmMerchantId: paytmMerchantId,
        orderId: orderId,
        amount: amount,
        successListener: successListener,
        failureListener: failureListener);
  }

  /// [uniPaymentGooglePayButton] is called,to integrate GooglePay payment gateway.
  /// Following parameters which are required need to pass while implementing,
  /// rest of are not neccesary as per need.
  /// [paymentConfigurationAsset] where you add asset path from asset folder.
  static Widget uniPaymentGooglePayButton({
    required String paymentConfigurationAsset,
    required failureListener(UniPaymentResponse response),
    required Function(UniPaymentResponse) successListener,
    required UniPaymentItemStatus uniPaymentItemStatus,
    required UniPaymentItemTypes uniPaymentItemTypes,
    required Function() onPressed,
    required String paymentLabel,
    required String payableAmount,
    UniPaymentGoogleButtonStyle? uniPaymentGoogleButtonStyle,
    UniPaymentGoogleButtonType? uniPaymentGoogleButtonType,
    double? height,
    double? width,
    Widget? loadingIndicator,
  }) {
    return GooglePayService().universalGooglePay(
      paymentConfigurationAsset: paymentConfigurationAsset,
      failureListener: failureListener,
      successListener: successListener,
      uniPaymentItemStatus: uniPaymentItemStatus,
      uniPaymentItemTypes: uniPaymentItemTypes,
      onPressed: onPressed,
      paymentLabel: paymentLabel,
      payableAmount: payableAmount,
      height: height,
      width: width ?? 350,
      loadingIndicator: loadingIndicator ?? CircularProgressIndicator(),
      uniPaymentGoogleButtonStyle: uniPaymentGoogleButtonStyle,
      uniPaymentGoogleButtonType: uniPaymentGoogleButtonType,
    );
  }

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
    required String redirectURL,
    required String transactionRef,
    required Function(UniPaymentResponse) successListener,
    required Function(UniPaymentResponse) failureListener,
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
        failureListener: failureListener,
        redirectURL: redirectURL,
        transactionRef: transactionRef);
  }

  /// [payPalBraintreePayment] is called,to integrate RazorpayPayment gateway.
  /// All parameters are [tokenizationKey], [emailId], [currencyCode], [countryCode], [] and [name] must be non-null.
  static payPalBraintreePayment({
    required String tokenizationKey,
    required double amount,
    required String emailId,
    required String name,
    String? currencyCode,
    String? countryCode,
  }) {
    return PaypalBrainTreeService().initPaypalBraintree(
      amount: amount,
      emailId: emailId,
      name: name,
      tokenizationKey: tokenizationKey,
      countryCode: countryCode,
      currencyCode: currencyCode,
    );
  }
}
