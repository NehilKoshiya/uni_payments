import 'package:flutter/material.dart';
import 'package:pay/pay.dart';
import 'package:uni_payments/model/unipaymentresponse.dart';

/// [UniPaymentItemStatus] is for managing status of payment.
enum UniPaymentItemStatus { unknown, pending, final_price }

/// [UniPaymentItemTypes] is for managing types of payment items.
enum UniPaymentItemTypes { item, total }

/// [UniPaymentGoogleButtonStyle] is for managing style of unipaymentgooglepaybutton.
enum UniPaymentGoogleButtonStyle { black, flat, white }

/// [UniPaymentGoogleButtonType] is for managing type of unipaymentgooglepaybutton.
enum UniPaymentGoogleButtonType {
  book,
  buy,
  checkout,
  donate,
  order,
  pay,
  plain,
  subscribe
}

class GooglePayService {
  Widget universalGooglePay({
    required String paymentConfigurationAsset,
    required failureListener(UniPaymentResponse response),
    required Function(UniPaymentResponse) successListener,
    required UniPaymentItemStatus uniPaymentItemStatus,
    required UniPaymentItemTypes uniPaymentItemTypes,
    required onPressed,
    required String paymentLabel,
    required String payableAmount,
    UniPaymentGoogleButtonStyle? uniPaymentGoogleButtonStyle,
    UniPaymentGoogleButtonType? uniPaymentGoogleButtonType,
    double? height,
    double? width,
    Widget? loadingIndicator,
  }) {
    /// [paymentlabel], [payableAmount], [status] and [type] passing values and parameters for ,
    /// send data to googlepay and getting response.
    List<PaymentItem> _paymentItems = [
      PaymentItem(
        label: paymentLabel,
        amount: payableAmount,
        status: uniPaymentItemStatus == UniPaymentItemStatus.pending
            ? PaymentItemStatus.pending
            : uniPaymentItemStatus == UniPaymentItemStatus.final_price
                ? PaymentItemStatus.final_price
                : PaymentItemStatus.unknown,
        type: uniPaymentItemTypes == UniPaymentItemTypes.item
            ? PaymentItemType.item
            : PaymentItemType.total,
      )
    ];

    /// return widget as googlepaybutton which is fully customizable
    return GooglePayButton(
      paymentConfigurationAsset: paymentConfigurationAsset,
      paymentItems: _paymentItems,
      height: height ?? 50,
      width: width ?? 150,
      // onPressed: onPressed,

      /// for handeling failures during payment occuring.
      onError: (data) {
        failureListener(
          UniPaymentResponse(
            "User canceled payment authorization",
            false,
            "paymentCanceled",
          ),
        );
      },

      /// for handeling success during payment occuring.
      onPaymentResult: (data) {
        successListener(
          UniPaymentResponse(
            "Successful Payment Done.",
            true,
            "payment",
          ),
        );
      },

      /// for handeling color and style of googlepay button.
      style: uniPaymentGoogleButtonStyle == UniPaymentGoogleButtonStyle.white
          ? GooglePayButtonStyle.white
          : uniPaymentGoogleButtonStyle == UniPaymentGoogleButtonStyle.black
              ? GooglePayButtonStyle.black
              : GooglePayButtonStyle.flat,

      /// when payment is runnning at that time this widget will shows.
      loadingIndicator: loadingIndicator ??
          const Center(
            child: CircularProgressIndicator(),
          ),

      /// for handeling different types of button UI.
      type: uniPaymentGoogleButtonType == UniPaymentGoogleButtonType.book
          ? GooglePayButtonType.book
          : uniPaymentGoogleButtonType == UniPaymentGoogleButtonType.buy
              ? GooglePayButtonType.buy
              : uniPaymentGoogleButtonType ==
                      UniPaymentGoogleButtonType.checkout
                  ? GooglePayButtonType.checkout
                  : uniPaymentGoogleButtonType ==
                          UniPaymentGoogleButtonType.donate
                      ? GooglePayButtonType.donate
                      : uniPaymentGoogleButtonType ==
                              UniPaymentGoogleButtonType.pay
                          ? GooglePayButtonType.pay
                          : uniPaymentGoogleButtonType ==
                                  UniPaymentGoogleButtonType.plain
                              ? GooglePayButtonType.plain
                              : uniPaymentGoogleButtonType ==
                                      UniPaymentGoogleButtonType.subscribe
                                  ? GooglePayButtonType.subscribe
                                  : GooglePayButtonType.order,
    );
  }
}
