import 'package:paytmpayments_allinonesdk/paytmpayments_allinonesdk.dart';

import '../models/payment_result.dart';

const _gatewayName = 'paytm';

/// Paytm All-in-One SDK integration. Internal — call via
/// `UniPayments.payWithPaytm(...)`.
class PaytmGateway {
  /// Create a stateless [PaytmGateway].
  const PaytmGateway();

  /// Start a Paytm transaction. Returns when the user finishes the flow.
  Future<PaymentResult> pay({
    required String merchantId,
    required String orderId,
    required String txnToken,
    required double amount,
    required bool useStagingEnvironment,
  }) async {
    final callback = useStagingEnvironment
        ? 'https://securegw-stage.paytm.in/theia/paytmCallback?ORDER_ID=$orderId'
        : 'https://securegw.paytm.in/theia/paytmCallback?ORDER_ID=$orderId';

    try {
      final response = await PaytmPaymentsAllinonesdk().startTransaction(
        merchantId,
        orderId,
        amount.toStringAsFixed(2),
        txnToken,
        callback,
        useStagingEnvironment,
        true,
      );

      if (response == null) {
        return const PaymentCancelled(
          gatewayName: _gatewayName,
          message: 'Paytm SDK returned no response',
        );
      }

      final payload = _normalise(response);
      final status = payload['STATUS']?.toString() ?? '';
      final txnId = payload['TXNID']?.toString() ?? '';
      final respCode = payload['RESPCODE']?.toString() ?? '';
      final respMsg = payload['RESPMSG']?.toString() ?? '';

      if (status == 'TXN_SUCCESS') {
        return PaymentSuccess(
          gatewayName: _gatewayName,
          transactionId: txnId,
          message: respMsg.isNotEmpty ? respMsg : 'Transaction successful',
          rawResponse: payload,
        );
      }

      // Paytm RESPCODE 141 = "User cancelled the transaction".
      if (respCode == '141' || status == 'TXN_CANCELLED') {
        return PaymentCancelled(
          gatewayName: _gatewayName,
          message: respMsg.isNotEmpty ? respMsg : 'User cancelled payment',
          rawResponse: payload,
        );
      }

      return PaymentFailure(
        gatewayName: _gatewayName,
        errorCode: respCode.isNotEmpty ? respCode : 'paytm_failed',
        message: respMsg.isNotEmpty ? respMsg : 'Transaction failed',
        rawResponse: payload,
      );
    } catch (e) {
      return PaymentFailure(
        gatewayName: _gatewayName,
        errorCode: 'paytm_error',
        message: e.toString(),
      );
    }
  }

  /// Paytm's iOS app-invoke flow wraps the payload under a top-level
  /// `response` key, while its redirection flow and the Android SDK return
  /// the fields directly. Normalise both into a single shape.
  Map<String, dynamic> _normalise(Map<dynamic, dynamic> raw) {
    final nested = raw['response'];
    if (nested is Map) return Map<String, dynamic>.from(nested);
    return Map<String, dynamic>.from(raw);
  }
}
