import 'dart:async';

import 'package:payu_checkoutpro_flutter/PayUConstantKeys.dart';
import 'package:payu_checkoutpro_flutter/payu_checkoutpro_flutter.dart';

import '../models/payment_result.dart';
import '../models/uni_customer.dart';

const _gatewayName = 'payu';

/// Called by [PayuGateway] every time PayU's SDK needs a request signed.
///
/// PayU requires each step of checkout to be signed with an HMAC hash
/// computed from your merchant **salt** — a secret that must never ship in
/// the client. Implement this by forwarding [hashRequest] to your backend
/// (which holds the salt) and returning its response verbatim; see
/// https://devguide.payu.in/flutter-sdk-integration/. This may be called
/// more than once per checkout.
typedef PayuHashGenerator =
    Future<Map<dynamic, dynamic>> Function(Map<dynamic, dynamic> hashRequest);

/// PayU CheckoutPro integration. Internal — call via
/// `UniPayments.payWithPayu(...)`.
class PayuGateway {
  /// Create a stateless [PayuGateway].
  const PayuGateway();

  /// Present PayU's CheckoutPro sheet and resolve once the user completes,
  /// cancels, or hits an error.
  Future<PaymentResult> pay({
    required String merchantKey,
    required double amount,
    required String productInfo,
    required UniCustomer customer,
    required String transactionId,
    required String successUrl,
    required String failureUrl,
    required PayuHashGenerator generateHash,
    required bool useStagingEnvironment,
    String merchantDisplayName = '',
    Map<String, dynamic>? additionalPaymentParams,
    Map<String, dynamic>? checkoutConfig,
  }) async {
    final completer = Completer<PaymentResult>();

    void resolve(PaymentResult result) {
      if (!completer.isCompleted) completer.complete(result);
    }

    late final PayUCheckoutProFlutter checkoutPro;
    checkoutPro = PayUCheckoutProFlutter(
      _Delegate(
        onGenerateHash: (hashRequest) {
          // Fire-and-forget from PayU's side too — it doesn't await this.
          unawaited(
            generateHash(
              hashRequest,
            ).then((hash) => checkoutPro.hashGenerated(hash: hash)),
          );
        },
        onSuccess: (response) {
          final data = _asMap(response);
          resolve(
            PaymentSuccess(
              gatewayName: _gatewayName,
              transactionId:
                  (data?['mihpayid'] ?? data?['txnid'] ?? transactionId)
                      .toString(),
              message: 'PayU payment completed',
              rawResponse: data,
            ),
          );
        },
        onFailure: (response) {
          final data = _asMap(response);
          resolve(
            PaymentFailure(
              gatewayName: _gatewayName,
              errorCode: data?['errorCode']?.toString() ?? 'payu_failed',
              message: data?['errorMsg']?.toString() ?? 'PayU payment failed',
              rawResponse: data,
            ),
          );
        },
        onCancel: (response) {
          resolve(
            PaymentCancelled(
              gatewayName: _gatewayName,
              message: 'User cancelled the PayU payment',
              rawResponse: _asMap(response),
            ),
          );
        },
        onError: (response) {
          final data = _asMap(response);
          resolve(
            PaymentFailure(
              gatewayName: _gatewayName,
              errorCode: data?['errorCode']?.toString() ?? 'payu_error',
              message: data?['errorMsg']?.toString() ?? 'PayU SDK error',
              rawResponse: data,
            ),
          );
        },
      ),
    );

    try {
      await checkoutPro.openCheckoutScreen(
        payUPaymentParams: <String, dynamic>{
          PayUPaymentParamKey.key: merchantKey,
          PayUPaymentParamKey.amount: amount.toStringAsFixed(2),
          PayUPaymentParamKey.productInfo: productInfo,
          PayUPaymentParamKey.firstName: customer.name,
          PayUPaymentParamKey.email: customer.email,
          PayUPaymentParamKey.phone: customer.phone ?? '',
          PayUPaymentParamKey.ios_surl: successUrl,
          PayUPaymentParamKey.ios_furl: failureUrl,
          PayUPaymentParamKey.android_surl: successUrl,
          PayUPaymentParamKey.android_furl: failureUrl,
          PayUPaymentParamKey.environment: useStagingEnvironment ? '1' : '0',
          PayUPaymentParamKey.transactionId: transactionId,
          PayUPaymentParamKey.additionalParam: ?additionalPaymentParams,
        },
        payUCheckoutProConfig: <String, dynamic>{
          if (merchantDisplayName.isNotEmpty)
            PayUCheckoutProConfigKeys.merchantName: merchantDisplayName,
          ...?checkoutConfig,
        },
      );
    } catch (e) {
      resolve(
        PaymentFailure(
          gatewayName: _gatewayName,
          errorCode: 'payu_error',
          message: e.toString(),
          rawResponse: <String, dynamic>{'exception': e.toString()},
        ),
      );
    }

    return completer.future;
  }
}

Map<String, dynamic>? _asMap(dynamic response) {
  if (response is Map) return Map<String, dynamic>.from(response);
  if (response == null) return null;
  return <String, dynamic>{'value': response};
}

/// Adapts PayU's callback-protocol interface to plain closures so
/// [PayuGateway] doesn't need to implement [PayUCheckoutProProtocol]
/// itself.
class _Delegate implements PayUCheckoutProProtocol {
  _Delegate({
    required this._onGenerateHash,
    required this._onSuccess,
    required this._onFailure,
    required this._onCancel,
    required this._onError,
  });

  final void Function(Map<dynamic, dynamic> response) _onGenerateHash;
  final void Function(dynamic response) _onSuccess;
  final void Function(dynamic response) _onFailure;
  final void Function(Map<dynamic, dynamic>? response) _onCancel;
  final void Function(Map<dynamic, dynamic>? response) _onError;

  @override
  generateHash(Map<dynamic, dynamic> response) => _onGenerateHash(response);

  @override
  onPaymentSuccess(dynamic response) => _onSuccess(response);

  @override
  onPaymentFailure(dynamic response) => _onFailure(response);

  @override
  onPaymentCancel(Map<dynamic, dynamic>? response) => _onCancel(response);

  @override
  onError(Map<dynamic, dynamic>? response) => _onError(response);
}
