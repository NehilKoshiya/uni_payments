import 'package:flutter/material.dart';

import 'gateways/airwallex_gateway.dart';
import 'gateways/apple_pay_gateway.dart';
import 'gateways/braintree_gateway.dart';
import 'gateways/cashfree_gateway.dart';
import 'gateways/flutterwave_gateway.dart';
import 'gateways/google_pay_gateway.dart';
import 'gateways/paystack_gateway.dart';
import 'gateways/paytm_gateway.dart';
import 'gateways/payu_gateway.dart';
import 'gateways/phonepe_gateway.dart';
import 'gateways/razorpay_gateway.dart';
import 'gateways/square_gateway.dart';
import 'gateways/stripe_gateway.dart';
import 'models/payment_result.dart';
import 'models/uni_customer.dart';
import 'models/wallet_provider.dart';

/// The single entry point for every gateway exposed by this package.
///
/// Every method is prefixed `payWith*` so IDE autocomplete lists all
/// available gateways together. Each one returns the same sealed
/// [PaymentResult] — three cases ([PaymentSuccess], [PaymentFailure],
/// [PaymentCancelled]) — so callers can exhaustively handle outcomes with
/// `switch`.
///
/// Where multiple gateways need the same buyer details, pass a single
/// [UniCustomer] rather than separate `email` / `name` / `phone` arguments.
class UniPayments {
  const UniPayments._();

  /// Open the Razorpay checkout sheet.
  ///
  /// [amount] is in the major currency unit (e.g. `25.50` for ₹25.50);
  /// the SDK is called with the minor-unit conversion automatically.
  ///
  /// [businessName] is shown as the merchant header inside Razorpay's UI —
  /// this is your store's name, not the buyer's. Buyer details come from
  /// [customer].
  ///
  /// By default this waits indefinitely for Razorpay's checkout to
  /// complete; pass [timeout] to bound the wait and get a [PaymentFailure]
  /// instead of hanging forever if the SDK never calls back.
  static Future<PaymentResult> payWithRazorpay({
    required String keyId,
    required double amount,
    required String businessName,
    required UniCustomer customer,
    String description = '',
    Color? themeColor,
    String currency = 'INR',
    Duration? timeout,
  }) {
    final guard = _validate(<String, String>{
      'keyId': keyId,
      'businessName': businessName,
      'customer.email': customer.email,
    }, amount);
    if (guard != null) return Future<PaymentResult>.value(guard);
    return const RazorpayGateway().pay(
      keyId: keyId,
      amount: amount,
      businessName: businessName,
      customer: customer,
      description: description,
      themeColor: themeColor,
      currency: currency,
      timeout: timeout,
    );
  }

  /// Initialise and present a Paystack payment modal.
  ///
  /// Pass your **secret key** — Paystack signs requests server-side via
  /// this key. In production, proxy through your own backend so the secret
  /// never ships in the client binary.
  static Future<PaymentResult> payWithPaystack({
    required BuildContext context,
    required String secretKey,
    required double amount,
    required UniCustomer customer,
    required String reference,
    required String callbackUrl,
    UniPaystackCurrency currency = UniPaystackCurrency.usd,
  }) {
    final guard = _validate(<String, String>{
      'secretKey': secretKey,
      'customer.email': customer.email,
      'reference': reference,
    }, amount);
    if (guard != null) return Future<PaymentResult>.value(guard);
    return const PaystackGateway().pay(
      context: context,
      secretKey: secretKey,
      amount: amount,
      customer: customer,
      reference: reference,
      callbackUrl: callbackUrl,
      currency: currency,
    );
  }

  /// Open Paytm's All-in-One SDK.
  ///
  /// [txnToken] must be fetched from your backend after creating an order
  /// with Paytm — see https://developer.paytm.com/docs/all-in-one-sdk/.
  static Future<PaymentResult> payWithPaytm({
    required String merchantId,
    required String orderId,
    required String txnToken,
    required double amount,
    bool useStagingEnvironment = false,
  }) {
    final guard = _validate(<String, String>{
      'merchantId': merchantId,
      'orderId': orderId,
      'txnToken': txnToken,
    }, amount);
    if (guard != null) return Future<PaymentResult>.value(guard);
    return const PaytmGateway().pay(
      merchantId: merchantId,
      orderId: orderId,
      txnToken: txnToken,
      amount: amount,
      useStagingEnvironment: useStagingEnvironment,
    );
  }

  /// Open Flutterwave's standard checkout.
  ///
  /// Only a `publicKey` is required — Flutterwave's standard widget handles
  /// encryption on its hosted modal, so do **not** ship secret/encryption
  /// keys in your client.
  static Future<PaymentResult> payWithFlutterwave({
    required BuildContext context,
    required String publicKey,
    required String currency,
    required double amount,
    required UniCustomer customer,
    required String txRef,
    required String redirectUrl,
    bool testMode = false,
    String paymentOptions = 'card, ussd, barter, payattitude',
  }) {
    final guard = _validate(<String, String>{
      'publicKey': publicKey,
      'currency': currency,
      'customer.email': customer.email,
      'txRef': txRef,
    }, amount);
    if (guard != null) return Future<PaymentResult>.value(guard);
    return const FlutterwaveGateway().pay(
      context: context,
      publicKey: publicKey,
      currency: currency,
      amount: amount,
      customer: customer,
      txRef: txRef,
      redirectUrl: redirectUrl,
      testMode: testMode,
      paymentOptions: paymentOptions,
    );
  }

  /// Present Cashfree's web checkout for a previously-created order.
  ///
  /// Cashfree is server-driven: your backend creates an order via their
  /// Orders API, which yields a `paymentSessionId`. Hand both that and
  /// the `orderId` here — Cashfree handles amount, customer details and
  /// payment methods server-side.
  ///
  /// Only one Cashfree payment can be in flight at a time — the upstream
  /// SDK is a process-wide singleton. A call made while another is still
  /// pending resolves immediately with a [PaymentFailure] rather than
  /// corrupting the first call's result.
  ///
  /// By default this waits indefinitely for Cashfree's checkout to
  /// complete; pass [timeout] to bound the wait and get a [PaymentFailure]
  /// instead of hanging forever if the SDK never calls back.
  ///
  /// See https://www.cashfree.com/docs/payments/online/mobile/flutter.
  static Future<PaymentResult> payWithCashfree({
    required String orderId,
    required String paymentSessionId,
    bool useStagingEnvironment = false,
    Duration? timeout,
  }) {
    final guard = _validate(<String, String>{
      'orderId': orderId,
      'paymentSessionId': paymentSessionId,
    });
    if (guard != null) return Future<PaymentResult>.value(guard);
    return const CashfreeGateway().pay(
      orderId: orderId,
      paymentSessionId: paymentSessionId,
      useStagingEnvironment: useStagingEnvironment,
      timeout: timeout,
    );
  }

  /// Initialise the PhonePe SDK and start a UPI transaction.
  ///
  /// PhonePe is fully server-driven: your backend assembles the
  /// transaction request (amount, merchantId, transactionId, signature),
  /// base64-encodes it, and you hand it here verbatim via [requestBody].
  ///
  /// [appSchema] is your iOS app's custom URL scheme (used by PhonePe to
  /// hand control back after the bank flow). Pass an empty string on
  /// Android. [flowId] is a tracking id that PhonePe correlates across
  /// your app and their SDK for debugging — pass a per-user or
  /// per-transaction string.
  ///
  /// See https://developer.phonepe.com/v1/docs/android-pg-mobile-integration.
  static Future<PaymentResult> payWithPhonepe({
    required String merchantId,
    required String flowId,
    required String requestBody,
    required String appSchema,
    bool useStagingEnvironment = false,
    bool enableLogging = false,
  }) {
    final guard = _validate(<String, String>{
      'merchantId': merchantId,
      'flowId': flowId,
      'requestBody': requestBody,
    });
    if (guard != null) return Future<PaymentResult>.value(guard);
    return const PhonepeGateway().pay(
      merchantId: merchantId,
      flowId: flowId,
      requestBody: requestBody,
      appSchema: appSchema,
      useStagingEnvironment: useStagingEnvironment,
      enableLogging: enableLogging,
    );
  }

  /// Present PayU's CheckoutPro sheet.
  ///
  /// PayU signs every checkout step with an HMAC hash computed from your
  /// merchant **salt** — a secret that must never ship in the client.
  /// [generateHash] is called (possibly more than once per checkout) with
  /// the raw request PayU wants signed; forward it to your backend and
  /// return its response verbatim. See
  /// https://devguide.payu.in/flutter-sdk-integration/.
  ///
  /// [successUrl] and [failureUrl] are used as both the Android and iOS
  /// redirect URLs. For OS-specific URLs or advanced CheckoutPro config
  /// (SI, split payments, EMI, …), pass [additionalPaymentParams] /
  /// [checkoutConfig] with PayU's raw keys from `PayUConstantKeys`.
  static Future<PaymentResult> payWithPayu({
    required String merchantKey,
    required double amount,
    required String productInfo,
    required UniCustomer customer,
    required String transactionId,
    required String successUrl,
    required String failureUrl,
    required PayuHashGenerator generateHash,
    bool useStagingEnvironment = false,
    String merchantDisplayName = '',
    Map<String, dynamic>? additionalPaymentParams,
    Map<String, dynamic>? checkoutConfig,
  }) {
    final guard = _validate(<String, String>{
      'merchantKey': merchantKey,
      'productInfo': productInfo,
      'customer.email': customer.email,
      'transactionId': transactionId,
      'successUrl': successUrl,
      'failureUrl': failureUrl,
    }, amount);
    if (guard != null) return Future<PaymentResult>.value(guard);
    return const PayuGateway().pay(
      merchantKey: merchantKey,
      amount: amount,
      productInfo: productInfo,
      customer: customer,
      transactionId: transactionId,
      successUrl: successUrl,
      failureUrl: failureUrl,
      generateHash: generateHash,
      useStagingEnvironment: useStagingEnvironment,
      merchantDisplayName: merchantDisplayName,
      additionalPaymentParams: additionalPaymentParams,
      checkoutConfig: checkoutConfig,
    );
  }

  /// Open the PayPal-branded Braintree Drop-In UI (also supports cards,
  /// Google Pay and Apple Pay when configured).
  ///
  /// Pass [applePayMerchantId] to enable Apple Pay inside the drop-in
  /// (you'll also need an Apple Pay merchant identifier registered in your
  /// iOS project's capabilities).
  static Future<PaymentResult> payWithPaypal({
    required BuildContext context,
    required String tokenizationKey,
    required double amount,
    required UniCustomer customer,
    String currency = 'USD',
    String countryCode = 'US',
    String? applePayMerchantId,
  }) {
    final guard = _validate(<String, String>{
      'tokenizationKey': tokenizationKey,
      'customer.email': customer.email,
      'customer.name': customer.name,
    }, amount);
    if (guard != null) return Future<PaymentResult>.value(guard);
    return const BraintreeGateway().pay(
      context: context,
      tokenizationKey: tokenizationKey,
      amount: amount,
      customer: customer,
      currency: currency,
      countryCode: countryCode,
      applePayMerchantId: applePayMerchantId,
    );
  }

  /// Present Stripe's PaymentSheet.
  ///
  /// [clientSecret] must come from a `PaymentIntent` created on your
  /// server — never hard-code it. Provide [customerId] +
  /// [customerEphemeralKeySecret] to enable the saved-card flow, and
  /// [applePayMerchantId] + [merchantCountryCode] to expose Apple/Google
  /// Pay inside the sheet.
  ///
  /// See https://stripe.com/docs/payments/accept-a-payment?platform=mobile.
  static Future<PaymentResult> payWithStripe({
    required String publishableKey,
    required String clientSecret,
    required String merchantDisplayName,
    String? customerId,
    String? customerEphemeralKeySecret,
    String? merchantCountryCode,
    String? applePayMerchantId,
    bool googlePayTestEnv = true,
  }) {
    final guard = _validate(<String, String>{
      'publishableKey': publishableKey,
      'clientSecret': clientSecret,
      'merchantDisplayName': merchantDisplayName,
    });
    if (guard != null) return Future<PaymentResult>.value(guard);
    return const StripeGateway().pay(
      publishableKey: publishableKey,
      clientSecret: clientSecret,
      merchantDisplayName: merchantDisplayName,
      customerId: customerId,
      customerEphemeralKeySecret: customerEphemeralKeySecret,
      merchantCountryCode: merchantCountryCode,
      applePayMerchantId: applePayMerchantId,
      googlePayTestEnv: googlePayTestEnv,
    );
  }

  /// Present Square's native card-entry sheet.
  ///
  /// This only tokenizes a card into a one-time-use nonce — it does not
  /// charge it. Send the resulting [PaymentSuccess.transactionId] (the
  /// nonce) to your backend and charge it via Square's Payments API.
  ///
  /// Sandbox vs. production is determined entirely by which
  /// [applicationId] you pass (sandbox app IDs look like
  /// `sandbox-sq0idb-...`) — there's no separate staging flag.
  static Future<PaymentResult> payWithSquare({
    required String applicationId,
    bool collectPostalCode = true,
  }) {
    final guard = _validate(<String, String>{'applicationId': applicationId});
    if (guard != null) return Future<PaymentResult>.value(guard);
    return const SquareGateway().pay(
      applicationId: applicationId,
      collectPostalCode: collectPostalCode,
    );
  }

  /// Present Airwallex's full payment sheet (cards, wallets, and local
  /// redirect methods, depending on what your account supports).
  ///
  /// [clientSecret] and [paymentIntentId] come from a `PaymentIntent` your
  /// server creates via Airwallex's API — never hard-code them.
  static Future<PaymentResult> payWithAirwallex({
    required String clientSecret,
    required String paymentIntentId,
    required double amount,
    required String currency,
    required String countryCode,
    String? customerId,
    bool useStagingEnvironment = false,
  }) {
    final guard = _validate(<String, String>{
      'clientSecret': clientSecret,
      'paymentIntentId': paymentIntentId,
      'currency': currency,
      'countryCode': countryCode,
    }, amount);
    if (guard != null) return Future<PaymentResult>.value(guard);
    return const AirwallexGateway().pay(
      clientSecret: clientSecret,
      paymentIntentId: paymentIntentId,
      amount: amount,
      currency: currency,
      countryCode: countryCode,
      customerId: customerId,
      useStagingEnvironment: useStagingEnvironment,
    );
  }

  /// Imperative Google Pay flow — gives you the same `Future<PaymentResult>`
  /// shape as the other gateways. Use this from a custom button's
  /// `onPressed`; or use [googlePayButton] for the native G Pay button.
  ///
  /// [paymentConfigurationJson] is the JSON string described at
  /// https://developers.google.com/pay/api/android/reference/request-objects.
  static Future<PaymentResult> payWithGooglePay({
    required String paymentConfigurationJson,
    required String lineItemLabel,
    required double amount,
    UniPaymentItemStatus lineItemStatus = UniPaymentItemStatus.finalPrice,
    UniPaymentItemType lineItemType = UniPaymentItemType.total,
  }) {
    final guard = _validate(<String, String>{
      'paymentConfigurationJson': paymentConfigurationJson,
      'lineItemLabel': lineItemLabel,
    }, amount);
    if (guard != null) return Future<PaymentResult>.value(guard);
    return GooglePayGateway.pay(
      paymentConfigurationJson: paymentConfigurationJson,
      lineItemLabel: lineItemLabel,
      amount: amount,
      lineItemStatus: lineItemStatus,
      lineItemType: lineItemType,
    );
  }

  /// Imperative Apple Pay flow. See [payWithGooglePay] for the equivalent
  /// docs.
  static Future<PaymentResult> payWithApplePay({
    required String paymentConfigurationJson,
    required String lineItemLabel,
    required double amount,
    UniPaymentItemStatus lineItemStatus = UniPaymentItemStatus.finalPrice,
    UniPaymentItemType lineItemType = UniPaymentItemType.total,
  }) {
    final guard = _validate(<String, String>{
      'paymentConfigurationJson': paymentConfigurationJson,
      'lineItemLabel': lineItemLabel,
    }, amount);
    if (guard != null) return Future<PaymentResult>.value(guard);
    return ApplePayGateway.pay(
      paymentConfigurationJson: paymentConfigurationJson,
      lineItemLabel: lineItemLabel,
      amount: amount,
      lineItemStatus: lineItemStatus,
      lineItemType: lineItemType,
    );
  }

  /// Returns true if the device has [wallet] set up and ready. Use this to
  /// gate showing the wallet button at all — the upstream `pay` package
  /// silently no-ops on unsupported platforms otherwise.
  static Future<bool> isWalletSupported(
    WalletProvider wallet,
    String paymentConfigurationJson,
  ) {
    return switch (wallet) {
      WalletProvider.googlePay => GooglePayGateway.isAvailable(
        paymentConfigurationJson,
      ),
      WalletProvider.applePay => ApplePayGateway.isAvailable(
        paymentConfigurationJson,
      ),
    };
  }

  /// Returns a fully-configured native Google Pay button widget.
  static Widget googlePayButton({
    required String paymentConfigurationJson,
    required String lineItemLabel,
    required double amount,
    required void Function(PaymentResult) onResult,
    UniPaymentItemStatus lineItemStatus = UniPaymentItemStatus.finalPrice,
    UniPaymentItemType lineItemType = UniPaymentItemType.total,
    UniGooglePayButtonType buttonType = UniGooglePayButtonType.pay,
    Widget? loadingIndicator,
    EdgeInsets margin = EdgeInsets.zero,
    VoidCallback? onPressed,
  }) => GooglePayGateway.button(
    paymentConfigurationJson: paymentConfigurationJson,
    lineItemLabel: lineItemLabel,
    amount: amount,
    onResult: onResult,
    lineItemStatus: lineItemStatus,
    lineItemType: lineItemType,
    buttonType: buttonType,
    loadingIndicator: loadingIndicator,
    margin: margin,
    onPressed: onPressed,
  );

  /// Returns a fully-configured native Apple Pay button widget.
  static Widget applePayButton({
    required String paymentConfigurationJson,
    required String lineItemLabel,
    required double amount,
    required void Function(PaymentResult) onResult,
    UniPaymentItemStatus lineItemStatus = UniPaymentItemStatus.finalPrice,
    UniPaymentItemType lineItemType = UniPaymentItemType.total,
    UniApplePayButtonStyle style = UniApplePayButtonStyle.black,
    UniApplePayButtonType type = UniApplePayButtonType.buy,
    Widget? loadingIndicator,
    EdgeInsets margin = EdgeInsets.zero,
    VoidCallback? onPressed,
  }) => ApplePayGateway.button(
    paymentConfigurationJson: paymentConfigurationJson,
    lineItemLabel: lineItemLabel,
    amount: amount,
    onResult: onResult,
    lineItemStatus: lineItemStatus,
    lineItemType: lineItemType,
    style: style,
    type: type,
    loadingIndicator: loadingIndicator,
    margin: margin,
    onPressed: onPressed,
  );

  /// Returns a [PaymentFailure] when an obvious input is bad — empty key,
  /// non-positive amount — so we never even hit the upstream SDK with junk.
  static PaymentResult? _validate(
    Map<String, String> requiredStrings, [
    double? amount,
  ]) {
    for (final entry in requiredStrings.entries) {
      if (entry.value.trim().isEmpty) {
        return PaymentFailure(
          errorCode: 'invalid_input',
          message: '${entry.key} must not be empty',
        );
      }
    }
    if (amount != null && amount <= 0) {
      return const PaymentFailure(
        errorCode: 'invalid_input',
        message: 'amount must be greater than zero',
      );
    }
    return null;
  }
}
