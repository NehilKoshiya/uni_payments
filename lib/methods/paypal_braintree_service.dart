import 'package:flutter_braintree/flutter_braintree.dart';

import '../model/unipaymentresponse.dart';

class PaypalBrainTreeService {
  initPaypalBraintree({
    required String tokenizationKey,
    required double amount,
    required String emailId,
    required String name,
    String? currencyCode,
    String? countryCode,
  }) async {
    /// initiate Braintree transaction
    var request = BraintreeDropInRequest(
      tokenizationKey: tokenizationKey,
      collectDeviceData: true,
      vaultManagerEnabled: true,
      requestThreeDSecureVerification: true,
      email: emailId,
      billingAddress: BraintreeBillingAddress(
        givenName: name,
        countryCodeAlpha2: countryCode ?? "US",
      ),
      googlePaymentRequest: BraintreeGooglePaymentRequest(
        totalPrice: amount.toString(),
        currencyCode: currencyCode ?? 'USD',
        billingAddressRequired: false,
      ),
      applePayRequest: BraintreeApplePayRequest(
        currencyCode: currencyCode ?? 'USD',
        supportedNetworks: [
          ApplePaySupportedNetworks.visa,
          ApplePaySupportedNetworks.masterCard,
          ApplePaySupportedNetworks.amex,
          ApplePaySupportedNetworks.discover,
        ],
        countryCode: countryCode ?? 'US',
        merchantIdentifier: '',
        displayName: name,
        paymentSummaryItems: [],
      ),
      paypalRequest: BraintreePayPalRequest(
        amount: amount.toString(),
        displayName: name,
      ),
      cardEnabled: true,
    );

    /// start the transaction for the paypal
    BraintreeDropInResult? braintreeDropInResult =
        await BraintreeDropIn.start(request);

    if (braintreeDropInResult == null) {
      /// return response for the success transaction events
      return UniPaymentResponse(
        "${braintreeDropInResult!.paymentMethodNonce.description}-${braintreeDropInResult.paymentMethodNonce.nonce}",
        false,
        braintreeDropInResult.deviceData.toString(),
      );
    } else {
      /// return response for the failure transaction events
      return UniPaymentResponse(
        "${braintreeDropInResult.paymentMethodNonce.description}-${braintreeDropInResult.paymentMethodNonce.paypalPayerId}-${braintreeDropInResult.paymentMethodNonce.nonce}",
        true,
        braintreeDropInResult.deviceData.toString(),
      );
    }
  }
}
