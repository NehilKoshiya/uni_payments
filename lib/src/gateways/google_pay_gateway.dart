import 'package:flutter/material.dart';
import 'package:pay/pay.dart';

import '../models/payment_result.dart';

const _gatewayName = 'google_pay';

/// Status of a payment line item (mirrors `pay`'s `PaymentItemStatus`).
enum UniPaymentItemStatus {
  /// The final amount is not yet known.
  pending,

  /// The displayed amount is the final amount.
  finalPrice,

  /// Status is not specified.
  unknown,
}

/// Type of a payment line item (mirrors `pay`'s `PaymentItemType`).
enum UniPaymentItemType {
  /// A single line item.
  item,

  /// A total line.
  total,
}

/// Visual variants of the Google Pay button.
enum UniGooglePayButtonType {
  /// "Book with G Pay".
  book,

  /// "Buy with G Pay".
  buy,

  /// "Check out with G Pay".
  checkout,

  /// "Donate with G Pay".
  donate,

  /// "Order with G Pay".
  order,

  /// "Pay with G Pay".
  pay,

  /// Plain G Pay logo.
  plain,

  /// "Subscribe with G Pay".
  subscribe,
}

extension UniPaymentItemStatusUpstream on UniPaymentItemStatus {
  PaymentItemStatus get upstream => switch (this) {
    UniPaymentItemStatus.pending => PaymentItemStatus.pending,
    UniPaymentItemStatus.finalPrice => PaymentItemStatus.final_price,
    UniPaymentItemStatus.unknown => PaymentItemStatus.unknown,
  };
}

extension UniPaymentItemTypeUpstream on UniPaymentItemType {
  PaymentItemType get upstream => switch (this) {
    UniPaymentItemType.item => PaymentItemType.item,
    UniPaymentItemType.total => PaymentItemType.total,
  };
}

extension on UniGooglePayButtonType {
  GooglePayButtonType get upstream => switch (this) {
    UniGooglePayButtonType.book => GooglePayButtonType.book,
    UniGooglePayButtonType.buy => GooglePayButtonType.buy,
    UniGooglePayButtonType.checkout => GooglePayButtonType.checkout,
    UniGooglePayButtonType.donate => GooglePayButtonType.donate,
    UniGooglePayButtonType.order => GooglePayButtonType.order,
    UniGooglePayButtonType.pay => GooglePayButtonType.pay,
    UniGooglePayButtonType.plain => GooglePayButtonType.plain,
    UniGooglePayButtonType.subscribe => GooglePayButtonType.subscribe,
  };
}

/// Google Pay integration. Internal — call via `UniPayments.payWithGooglePay()`
/// or `UniPayments.googlePayButton(...)`.
class GooglePayGateway {
  const GooglePayGateway._();

  /// Imperative Google Pay flow — call this from a button's `onPressed` and
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
        PayProvider.google_pay: PaymentConfiguration.fromJsonString(
          paymentConfigurationJson,
        ),
      });
      final result = await pay.showPaymentSelector(PayProvider.google_pay, [
        _buildItem(lineItemLabel, amount, lineItemStatus, lineItemType),
      ]);

      final token = _extractToken(result);

      return PaymentSuccess(
        gatewayName: _gatewayName,
        transactionId: token ?? '',
        message: 'Google Pay token received',
        rawResponse: result,
      );
    } catch (e) {
      // pay 3.x fires the same error path for both genuine errors and user
      // cancellation — surface as a PaymentFailure. Inspect the message if
      // you need to differentiate.
      return PaymentFailure(
        gatewayName: _gatewayName,
        errorCode: 'google_pay_error',
        message: e.toString(),
      );
    }
  }

  /// Build a [GooglePayButton] wired into a [PaymentResult] callback.
  static Widget button({
    required String paymentConfigurationJson,
    required String lineItemLabel,
    required double amount,
    required void Function(PaymentResult) onResult,
    required UniPaymentItemStatus lineItemStatus,
    required UniPaymentItemType lineItemType,
    required UniGooglePayButtonType buttonType,
    required EdgeInsets margin,
    Widget? loadingIndicator,
    VoidCallback? onPressed,
  }) {
    final paymentItems = [
      _buildItem(lineItemLabel, amount, lineItemStatus, lineItemType),
    ];

    return GooglePayButton(
      paymentConfiguration: PaymentConfiguration.fromJsonString(
        paymentConfigurationJson,
      ),
      paymentItems: paymentItems,
      type: buttonType.upstream,
      margin: margin,
      onPressed: onPressed,
      onPaymentResult: (result) {
        onResult(
          PaymentSuccess(
            gatewayName: _gatewayName,
            transactionId: _extractToken(result) ?? '',
            message: 'Google Pay token received',
            rawResponse: result,
          ),
        );
      },
      onError: (error) {
        onResult(
          PaymentFailure(
            gatewayName: _gatewayName,
            errorCode: 'google_pay_error',
            message: error.toString(),
          ),
        );
      },
      loadingIndicator:
          loadingIndicator ?? const Center(child: CircularProgressIndicator()),
    );
  }

  /// Probe whether the current device has Google Pay configured.
  static Future<bool> isAvailable(String paymentConfigurationJson) async {
    try {
      final pay = Pay({
        PayProvider.google_pay: PaymentConfiguration.fromJsonString(
          paymentConfigurationJson,
        ),
      });
      return await pay.userCanPay(PayProvider.google_pay);
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

  /// Google Pay's payload format:
  /// `{ paymentMethodData: { tokenizationData: { token: '...' } } }`.
  static String? _extractToken(Map<String, dynamic> result) {
    final pmData = result['paymentMethodData'];
    if (pmData is Map) {
      final tokData = pmData['tokenizationData'];
      if (tokData is Map) return tokData['token']?.toString();
    }
    return null;
  }
}
