import 'package:flutter/material.dart';
import 'package:pay/pay.dart';

import '../models/payment_result.dart';
import 'google_pay_gateway.dart';

const _gatewayName = 'apple_pay';

/// Visual style of the Apple Pay button.
enum UniApplePayButtonStyle {
  /// Solid black.
  black,

  /// Outlined.
  whiteOutline,

  /// Solid white.
  white,
}

/// Visual variant of the Apple Pay button.
enum UniApplePayButtonType {
  /// Plain "Pay" call to action.
  plain,

  /// "Buy with Apple Pay".
  buy,

  /// "Set up Apple Pay".
  setUp,

  /// "Pay with Apple Pay".
  inStore,

  /// "Donate with Apple Pay".
  donate,

  /// "Check out with Apple Pay".
  checkout,

  /// "Book with Apple Pay".
  book,

  /// "Subscribe with Apple Pay".
  subscribe,

  /// "Reload with Apple Pay".
  reload,

  /// "Add money with Apple Pay".
  addMoney,

  /// "Top up with Apple Pay".
  topUp,

  /// "Order with Apple Pay".
  order,

  /// "Rent with Apple Pay".
  rent,

  /// "Support with Apple Pay".
  support,

  /// "Contribute with Apple Pay".
  contribute,

  /// "Tip with Apple Pay".
  tip,
}

extension on UniApplePayButtonStyle {
  ApplePayButtonStyle get upstream => switch (this) {
    UniApplePayButtonStyle.black => ApplePayButtonStyle.black,
    UniApplePayButtonStyle.whiteOutline => ApplePayButtonStyle.whiteOutline,
    UniApplePayButtonStyle.white => ApplePayButtonStyle.white,
  };
}

extension on UniApplePayButtonType {
  ApplePayButtonType get upstream => switch (this) {
    UniApplePayButtonType.plain => ApplePayButtonType.plain,
    UniApplePayButtonType.buy => ApplePayButtonType.buy,
    UniApplePayButtonType.setUp => ApplePayButtonType.setUp,
    UniApplePayButtonType.inStore => ApplePayButtonType.inStore,
    UniApplePayButtonType.donate => ApplePayButtonType.donate,
    UniApplePayButtonType.checkout => ApplePayButtonType.checkout,
    UniApplePayButtonType.book => ApplePayButtonType.book,
    UniApplePayButtonType.subscribe => ApplePayButtonType.subscribe,
    UniApplePayButtonType.reload => ApplePayButtonType.reload,
    UniApplePayButtonType.addMoney => ApplePayButtonType.addMoney,
    UniApplePayButtonType.topUp => ApplePayButtonType.topUp,
    UniApplePayButtonType.order => ApplePayButtonType.order,
    UniApplePayButtonType.rent => ApplePayButtonType.rent,
    UniApplePayButtonType.support => ApplePayButtonType.support,
    UniApplePayButtonType.contribute => ApplePayButtonType.contribute,
    UniApplePayButtonType.tip => ApplePayButtonType.tip,
  };
}

/// Apple Pay integration. Internal — call via `UniPayments.payWithApplePay()`
/// or `UniPayments.applePayButton(...)`.
class ApplePayGateway {
  const ApplePayGateway._();

  /// Imperative Apple Pay flow — call this from a button's `onPressed` and
  /// `await` the result like every other gateway.
  static Future<PaymentResult> pay({
    required String paymentConfigurationJson,
    required String lineItemLabel,
    required double amount,
    UniPaymentItemStatus lineItemStatus = UniPaymentItemStatus.finalPrice,
    UniPaymentItemType lineItemType = UniPaymentItemType.total,
  }) async {
    try {
      final pay = Pay({
        PayProvider.apple_pay: PaymentConfiguration.fromJsonString(
          paymentConfigurationJson,
        ),
      });
      final result = await pay.showPaymentSelector(PayProvider.apple_pay, [
        _buildItem(lineItemLabel, amount, lineItemStatus, lineItemType),
      ]);

      return PaymentSuccess(
        gatewayName: _gatewayName,
        transactionId: _extractTransactionId(result) ?? '',
        message: 'Apple Pay token received',
        rawResponse: result,
      );
    } catch (e) {
      return PaymentFailure(
        gatewayName: _gatewayName,
        errorCode: 'apple_pay_error',
        message: e.toString(),
      );
    }
  }

  /// Build an [ApplePayButton] wired into a [PaymentResult] callback.
  static Widget button({
    required String paymentConfigurationJson,
    required String lineItemLabel,
    required double amount,
    required void Function(PaymentResult) onResult,
    required UniPaymentItemStatus lineItemStatus,
    required UniPaymentItemType lineItemType,
    required UniApplePayButtonStyle style,
    required UniApplePayButtonType type,
    required EdgeInsets margin,
    Widget? loadingIndicator,
    VoidCallback? onPressed,
  }) {
    final paymentItems = [
      _buildItem(lineItemLabel, amount, lineItemStatus, lineItemType),
    ];

    return ApplePayButton(
      paymentConfiguration: PaymentConfiguration.fromJsonString(
        paymentConfigurationJson,
      ),
      paymentItems: paymentItems,
      style: style.upstream,
      type: type.upstream,
      margin: margin,
      onPressed: onPressed,
      onPaymentResult: (result) {
        onResult(
          PaymentSuccess(
            gatewayName: _gatewayName,
            transactionId: _extractTransactionId(result) ?? '',
            message: 'Apple Pay token received',
            rawResponse: result,
          ),
        );
      },
      onError: (error) {
        onResult(
          PaymentFailure(
            gatewayName: _gatewayName,
            errorCode: 'apple_pay_error',
            message: error.toString(),
          ),
        );
      },
      loadingIndicator:
          loadingIndicator ?? const Center(child: CircularProgressIndicator()),
    );
  }

  /// Probe whether the current device has Apple Pay configured.
  static Future<bool> isAvailable(String paymentConfigurationJson) async {
    try {
      final pay = Pay({
        PayProvider.apple_pay: PaymentConfiguration.fromJsonString(
          paymentConfigurationJson,
        ),
      });
      return await pay.userCanPay(PayProvider.apple_pay);
    } catch (_) {
      return false;
    }
  }

  static PaymentItem _buildItem(
    String label,
    double amount,
    UniPaymentItemStatus status,
    UniPaymentItemType type,
  ) {
    return PaymentItem(
      label: label,
      amount: amount.toStringAsFixed(2),
      status: status.upstream,
      type: type.upstream,
    );
  }

  /// Apple Pay's payload format varies per processor, but most expose
  /// `result.token.transactionIdentifier`.
  static String? _extractTransactionId(Map<String, dynamic> result) {
    final token = result['token'];
    if (token is Map) return token['transactionIdentifier']?.toString();
    return null;
  }
}
