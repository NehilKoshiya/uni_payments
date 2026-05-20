// ignore_for_file: deprecated_member_use
//
// PayPal is sunsetting the Braintree Drop-In SDK on 2026-07-14. The
// replacement is a custom UI built on `Braintree.tokenizeCreditCard()` and
// the standalone PayPal Web flow; tracked for a follow-up release of this
// package. Until the cut-off the Drop-In is still functional.
import 'package:braintree_flutter_plus/braintree_flutter_plus.dart';

import '../models/payment_result.dart';
import '../models/uni_customer.dart';

const _gatewayName = 'paypal';

/// Braintree Drop-In integration (PayPal, card, Google Pay, Apple Pay).
/// Internal — call via `UniPayments.payWithPaypal(...)`.
class BraintreeGateway {
  /// Create a stateless [BraintreeGateway].
  const BraintreeGateway();

  /// Present the Braintree Drop-In UI.
  ///
  /// Returns [PaymentCancelled] when the user dismisses the sheet without
  /// selecting a payment method.
  Future<PaymentResult> pay({
    required String tokenizationKey,
    required double amount,
    required UniCustomer customer,
    required String currency,
    required String countryCode,
    String? applePayMerchantId,
  }) async {
    try {
      final amountStr = amount.toStringAsFixed(2);

      final request = BraintreeDropInRequest(
        tokenizationKey: tokenizationKey,
        collectDeviceData: true,
        vaultManagerEnabled: true,
        requestThreeDSecureVerification: true,
        email: customer.email,
        billingAddress: BraintreeBillingAddress(
          givenName: customer.name,
          countryCodeAlpha2: countryCode,
        ),
        googlePaymentRequest: BraintreeGooglePaymentRequest(
          totalPrice: amountStr,
          currencyCode: currency,
          billingAddressRequired: false,
        ),
        applePayRequest: applePayMerchantId == null
            ? null
            : BraintreeApplePayRequest(
                currencyCode: currency,
                supportedNetworks: const [
                  ApplePaySupportedNetworks.visa,
                  ApplePaySupportedNetworks.masterCard,
                  ApplePaySupportedNetworks.amex,
                  ApplePaySupportedNetworks.discover,
                ],
                countryCode: countryCode,
                merchantIdentifier: applePayMerchantId,
                displayName: customer.name,
                paymentSummaryItems: const [],
              ),
        paypalRequest: BraintreePayPalRequest(
          amount: amountStr,
          displayName: customer.name,
        ),
        cardEnabled: true,
      );

      final result = await BraintreeDropIn.start(request);

      if (result == null) {
        return const PaymentCancelled(
          gatewayName: _gatewayName,
          message: 'User dismissed the Braintree drop-in sheet',
        );
      }

      final nonce = result.paymentMethodNonce;
      return PaymentSuccess(
        gatewayName: _gatewayName,
        transactionId: nonce.nonce,
        message: nonce.description,
        rawResponse: <String, dynamic>{
          'nonce': nonce.nonce,
          'description': nonce.description,
          'typeLabel': nonce.typeLabel,
          'paypalPayerId': nonce.paypalPayerId,
          'isDefault': nonce.isDefault,
          'deviceData': result.deviceData,
        },
      );
    } catch (e) {
      return PaymentFailure(
        gatewayName: _gatewayName,
        errorCode: 'paypal_error',
        message: e.toString(),
      );
    }
  }
}
