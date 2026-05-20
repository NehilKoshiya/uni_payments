import 'package:phonepe_payment_sdk/phonepe_payment_sdk.dart';

import '../models/payment_result.dart';

const _gatewayName = 'phonepe';

/// PhonePe (India, UPI) integration. Internal — call via
/// `UniPayments.payWithPhonepe(...)`.
///
/// PhonePe's flow is fully server-driven: your backend assembles the
/// transaction request (amount, merchantId, transactionId, signature),
/// base64-encodes it, and you hand it here verbatim.
class PhonepeGateway {
  /// Create a stateless [PhonepeGateway].
  const PhonepeGateway();

  /// Initialise the PhonePe SDK and start a transaction.
  ///
  /// [requestBody] is the base64-encoded JSON payload your backend
  /// generates per
  /// https://developer.phonepe.com/v1/docs/android-pg-mobile-integration.
  /// [appSchema] is your iOS app's custom URL scheme — pass an empty
  /// string on Android.
  Future<PaymentResult> pay({
    required String merchantId,
    required String flowId,
    required String requestBody,
    required String appSchema,
    required bool useStagingEnvironment,
    bool enableLogging = false,
  }) async {
    try {
      final initialised = await PhonePePaymentSdk.init(
        useStagingEnvironment ? 'SANDBOX' : 'PRODUCTION',
        merchantId,
        flowId,
        enableLogging,
      );

      if (!initialised) {
        return const PaymentFailure(
          gatewayName: _gatewayName,
          errorCode: 'phonepe_init_failed',
          message: 'PhonePe SDK refused to initialise',
        );
      }

      final response = await PhonePePaymentSdk.startTransaction(
        requestBody,
        appSchema,
      );

      if (response == null) {
        return const PaymentFailure(
          gatewayName: _gatewayName,
          errorCode: 'phonepe_no_response',
          message: 'PhonePe SDK returned no response',
        );
      }

      final payload = Map<String, dynamic>.from(response);
      final status = payload['status']?.toString().toUpperCase() ?? '';
      final error = payload['error']?.toString();

      switch (status) {
        case 'SUCCESS':
          return PaymentSuccess(
            gatewayName: _gatewayName,
            // PhonePe does not return the transaction id in the SDK
            // callback — the merchant fetches it via the status API using
            // their own merchantTransactionId. Surface the raw payload so
            // callers can correlate.
            transactionId: '',
            message: 'PhonePe payment completed',
            rawResponse: payload,
          );
        case 'INTERRUPTED':
          return PaymentCancelled(
            gatewayName: _gatewayName,
            message: error ?? 'User interrupted the PhonePe flow',
            rawResponse: payload,
          );
        default:
          return PaymentFailure(
            gatewayName: _gatewayName,
            errorCode: status.isNotEmpty ? status : 'phonepe_failed',
            message: error ?? 'PhonePe transaction failed',
            rawResponse: payload,
          );
      }
    } catch (e) {
      return PaymentFailure(
        gatewayName: _gatewayName,
        errorCode: 'phonepe_error',
        message: e.toString(),
      );
    }
  }
}
