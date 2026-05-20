<div align="center">

# Uni Payments

**Ten payment gateways. One `Future<PaymentResult>`. Zero glue code.**

A unified Flutter API over Razorpay · Stripe · PayPal · Paystack · Flutterwave · Paytm · Cashfree · PhonePe · Google Pay · Apple Pay.

[![pub](https://img.shields.io/pub/v/uni_payments.svg?logo=dart&color=0175C2&label=pub.dev)](https://pub.dev/packages/uni_payments)
[![pub points](https://img.shields.io/pub/points/uni_payments?logo=dart&color=0175C2)](https://pub.dev/packages/uni_payments/score)
[![flutter](https://img.shields.io/badge/Flutter-3.32%2B-02569B?logo=flutter)](https://flutter.dev)
[![dart](https://img.shields.io/badge/Dart-3.8%2B-0175C2?logo=dart)](https://dart.dev)
[![license](https://img.shields.io/badge/license-Apache--2.0-blue.svg)](LICENSE)

</div>

```dart
final result = await UniPayments.payWithRazorpay(
  keyId: 'YOUR_RAZORPAY_KEY_ID',
  amount: 25.00,
  businessName: 'Acme Inc',
  customer: UniCustomer(name: 'Ada', email: 'ada@x.com', phone: '9999999999'),
);

switch (result) {
  case PaymentSuccess(:final transactionId): /* verify on backend */
  case PaymentFailure(:final errorCode, :final message): /* show error */
  case PaymentCancelled(): /* user dismissed the sheet */
}
```

> Swap `payWithRazorpay` for `payWithStripe`, `payWithPaypal`, `payWithGooglePay`, … the call shape is identical for every gateway.

---

## Why this exists

Six gateway SDKs ship six call shapes, six response objects, six ways the user can cancel. Even when you wrap them, "user closed the sheet" usually disappears into a generic catch.

Uni Payments replaces all of that with a single sealed result type that the **Dart compiler forces you to exhaust** — every `switch` you write is checked at compile time, so you can't forget the cancel case again.

| | Before | With Uni Payments |
| --- | --- | --- |
| API per gateway | Different class, different callbacks, different error shape | `UniPayments.payWith*(...)` everywhere |
| Cancellation | Hidden inside `catch (e)` or a stringy status | `PaymentCancelled` — a real type |
| Verification | Dig through gateway-specific JSON | `result.transactionId` + `result.rawResponse` |
| Native setup | 6 different setup guides | Documented per gateway here |

---

## Gateways

| Gateway      | Region       | SDK                                                       | Imperative call                       | Native button                        |
| ------------ | ------------ | --------------------------------------------------------- | ------------------------------------- | ------------------------------------ |
| Razorpay     | India        | `razorpay_flutter`            | `payWithRazorpay`                     | —                                    |
| Stripe       | Global       | `flutter_stripe`              | `payWithStripe`                       | —                                    |
| PayPal       | Global       | `braintree_flutter_plus`      | `payWithPaypal`                       | —                                    |
| Paystack     | Africa       | `flutter_paystack_max`        | `payWithPaystack`                     | —                                    |
| Flutterwave  | Africa       | `flutterwave_standard`        | `payWithFlutterwave`                  | —                                    |
| Paytm        | India        | `paytmpayments_allinonesdk`   | `payWithPaytm`                        | —                                    |
| Cashfree     | India        | `flutter_cashfree_pg_sdk`     | `payWithCashfree`                     | —                                    |
| PhonePe      | India · UPI  | `phonepe_payment_sdk`         | `payWithPhonepe`                      | —                                    |
| Google Pay   | Android      | `pay`                         | `payWithGooglePay`                    | `googlePayButton(...)`               |
| Apple Pay    | iOS          | `pay`                         | `payWithApplePay`                     | `applePayButton(...)`                |

Every imperative call returns `Future<PaymentResult>`. Wallet buttons exist because Google + Apple's brand guidelines require their own button design.

---

## Install

```yaml
dependencies:
  uni_payments: ^1.0.0
```

```sh
flutter pub add uni_payments
```

```dart
import 'package:uni_payments/uni_payments.dart';
```

### Platform requirements

| Platform | Minimum                                                                                  |
| -------- | ---------------------------------------------------------------------------------------- |
| Flutter  | **3.32+** · Dart **3.8+** (sealed classes + switch expressions)                          |
| Android  | **`minSdkVersion 23`** — modern Stripe / Razorpay / PhonePe builds need it               |
| iOS      | **iOS 15+** — driven by PhonePe's IntentSDK constraint                                   |

### Required extra setup

<details>
<summary><b>PhonePe needs a private Maven repo on Android</b></summary>

PhonePe's `IntentSDK` is hosted on PhonePe's CloudRepo, not on Maven Central. Add the repository to your app's `android/build.gradle.kts`:

```kotlin
allprojects {
  repositories {
    google()
    mavenCentral()
    maven { url = uri("https://phonepe.mycloudrepo.io/public/repositories/phonepe-intentsdk-android") }
  }
}
```

Groovy DSL equivalent in `android/build.gradle`:

```groovy
maven { url 'https://phonepe.mycloudrepo.io/public/repositories/phonepe-intentsdk-android' }
```

</details>

---

## Core types

### `UniCustomer`

Pass once, reuse everywhere a gateway prefills checkout fields.

```dart
const customer = UniCustomer(
  name: 'Ada Lovelace',
  email: 'ada@example.com',
  phone: '9999999999', // optional
);
```

### `PaymentResult`

```dart
sealed class PaymentResult {
  String? gatewayName;       // 'razorpay', 'stripe', 'apple_pay', …
  String? message;
  Map<String, dynamic>? rawResponse;
}

final class PaymentSuccess   extends PaymentResult { String transactionId; }
final class PaymentFailure   extends PaymentResult { String errorCode; String message; }
final class PaymentCancelled extends PaymentResult { }
```

`rawResponse` holds the untouched gateway payload — useful for audit logs and webhook reconciliation.

### `UniPayments.isWalletSupported`

Probe before rendering a wallet button — the underlying `pay` package silently no-ops on unsupported platforms.

```dart
final canApplePay = await UniPayments.isWalletSupported(
  WalletProvider.applePay,
  configJson,
);
```

---

## Per-gateway cookbook

<details>
<summary><b>Razorpay</b></summary>

```dart
final result = await UniPayments.payWithRazorpay(
  keyId: 'YOUR_RAZORPAY_KEY_ID',
  amount: 25.00,                    // major units (₹25.00)
  businessName: 'Acme Inc',         // merchant header inside the sheet
  customer: customer,
  description: 'Pro subscription',
  themeColor: Colors.indigo,        // Color, not '#RRGGBB'
  currency: 'INR',
);
```

</details>

<details>
<summary><b>Stripe</b></summary>

```dart
final result = await UniPayments.payWithStripe(
  publishableKey: 'YOUR_STRIPE_PUBLISHABLE_KEY',
  clientSecret: 'YOUR_PAYMENT_INTENT_CLIENT_SECRET',     // from your server
  merchantDisplayName: 'Acme Inc',
  merchantCountryCode: 'US',

  // Optional — Apple Pay / Google Pay inside the PaymentSheet
  applePayMerchantId: 'merchant.com.acme.app',
  googlePayTestEnv: true,

  // Optional — saved cards (ephemeral key from your server)
  customerId: 'cus_xxx',
  customerEphemeralKeySecret: 'ek_test_xxx',
);
```

</details>

<details>
<summary><b>PayPal</b> (Braintree drop-in)</summary>

```dart
final result = await UniPayments.payWithPaypal(
  tokenizationKey: 'YOUR_BRAINTREE_TOKENIZATION_KEY',
  amount: 25.00,
  customer: customer,
  currency: 'USD',
  countryCode: 'US',
  applePayMerchantId: 'merchant.com.acme', // optional
);
```

</details>

<details>
<summary><b>Paystack</b></summary>

```dart
final result = await UniPayments.payWithPaystack(
  context: context,
  secretKey: 'YOUR_PAYSTACK_SECRET_KEY',
  amount: 25.00,
  customer: customer,
  reference: 'ref_${DateTime.now().millisecondsSinceEpoch}',
  callbackUrl: 'https://acme.dev/paystack/callback',
  currency: UniPaystackCurrency.usd,
);
```

</details>

<details>
<summary><b>Flutterwave</b></summary>

```dart
final result = await UniPayments.payWithFlutterwave(
  context: context,
  publicKey: 'YOUR_FLUTTERWAVE_PUBLIC_KEY',
  currency: 'NGN',
  amount: 25.00,
  customer: customer,
  txRef: 'tx_${DateTime.now().millisecondsSinceEpoch}',
  redirectUrl: 'https://acme.dev/flutterwave/return',
  testMode: true,
);
```

> Standard checkout only needs your **public** key. Encryption happens on Flutterwave's hosted modal.

</details>

<details>
<summary><b>Paytm</b></summary>

```dart
// txnToken is issued by your backend via Paytm's initiateTransaction API.
final result = await UniPayments.payWithPaytm(
  merchantId: 'YOUR_MERCHANT_ID',
  orderId: 'order_${DateTime.now().millisecondsSinceEpoch}',
  txnToken: 'YOUR_TXN_TOKEN',
  amount: 25.00,
  useStagingEnvironment: true,
);
```

</details>

<details>
<summary><b>Cashfree</b></summary>

```dart
// orderId + paymentSessionId come from your backend's call to the
// Cashfree Orders API.
final result = await UniPayments.payWithCashfree(
  orderId: 'order_${DateTime.now().millisecondsSinceEpoch}',
  paymentSessionId: 'session_xxx',
  useStagingEnvironment: true,
);
```

</details>

<details>
<summary><b>PhonePe</b></summary>

```dart
// requestBody is a base64-encoded JSON request your backend signs.
final result = await UniPayments.payWithPhonepe(
  merchantId: 'YOUR_MERCHANT_ID',
  flowId: 'flow_${DateTime.now().millisecondsSinceEpoch}',
  requestBody: '<base64-encoded JSON from your backend>',
  appSchema: 'unipaymentsdemo', // iOS URL scheme; '' on Android
  useStagingEnvironment: true,
);
```

> Also requires the Maven repo described in [Required extra setup](#required-extra-setup).

</details>

<details>
<summary><b>Google Pay</b></summary>

```dart
// Imperative
final result = await UniPayments.payWithGooglePay(
  paymentConfigurationJson: configJson,
  lineItemLabel: 'Total',
  amount: 25.00,
);

// Native button
UniPayments.googlePayButton(
  paymentConfigurationJson: configJson,
  lineItemLabel: 'Total',
  amount: 25.00,
  buttonType: UniGooglePayButtonType.pay,
  onResult: (PaymentResult result) { /* … */ },
);
```

</details>

<details>
<summary><b>Apple Pay</b></summary>

```dart
final result = await UniPayments.payWithApplePay(
  paymentConfigurationJson: configJson,
  lineItemLabel: 'Total',
  amount: 25.00,
);

UniPayments.applePayButton(
  paymentConfigurationJson: configJson,
  lineItemLabel: 'Total',
  amount: 25.00,
  type: UniApplePayButtonType.buy,
  onResult: (PaymentResult result) { /* … */ },
);
```

</details>

---

## Demo app

The repo ships a fully-styled demo with all ten gateways wired up — animated gradient background, glass-morphism tiles, error toasts, haptic feedback on each outcome.

```sh
git clone https://github.com/NehilKoshiya/uni_payments
cd uni_payments/example
flutter pub get
flutter run
```

---

## Security notes

* Never ship secret keys or `clientSecret`s in your binary — generate them on your server and pass them in.
* Always verify `PaymentSuccess` server-side before fulfilling. Client-side success only means the SDK *said* so.
* `rawResponse` carries the untouched gateway payload — log it for audit + webhook reconciliation.

---

## Contributing

* Bug or feature request — [open an issue](https://github.com/NehilKoshiya/uni_payments/issues).
* Sending a PR — `flutter analyze` must be clean and `flutter test` must pass.
* Found this useful? A ⭐ on [GitHub](https://github.com/NehilKoshiya/uni_payments) goes a long way.

---

<sub>Apache 2.0 · © Nehil Koshiya</sub>
