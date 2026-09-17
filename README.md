<div align="center">

# Uni Payments

**Thirteen payment gateways. One `Future<PaymentResult>`. Zero glue code.**

A unified Flutter API over Razorpay · Stripe · PayPal · Paystack · Flutterwave · Paytm · Cashfree · PhonePe · PayU · Square · Airwallex · Google Pay · Apple Pay.

[![pub](https://img.shields.io/pub/v/uni_payments.svg?logo=dart&color=0175C2&label=pub.dev)](https://pub.dev/packages/uni_payments)
[![pub points](https://img.shields.io/pub/points/uni_payments?logo=dart&color=0175C2)](https://pub.dev/packages/uni_payments/score)
[![flutter](https://img.shields.io/badge/Flutter-3.41%2B-02569B?logo=flutter)](https://flutter.dev)
[![dart](https://img.shields.io/badge/Dart-3.8%2B-0175C2?logo=dart)](https://dart.dev)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

<br>

![Razorpay](https://img.shields.io/badge/Razorpay-3395FF?style=for-the-badge&logo=razorpay&logoColor=white)
![Stripe](https://img.shields.io/badge/Stripe-635BFF?style=for-the-badge&logo=stripe&logoColor=white)
![PayPal](https://img.shields.io/badge/PayPal-00457C?style=for-the-badge&logo=paypal&logoColor=white)
![Paystack](https://img.shields.io/badge/Paystack-00C3F7?style=for-the-badge&logoColor=white)
![Flutterwave](https://img.shields.io/badge/Flutterwave-FB6020?style=for-the-badge&logoColor=white)
![Paytm](https://img.shields.io/badge/Paytm-00BAF2?style=for-the-badge&logo=paytm&logoColor=white)
![Cashfree](https://img.shields.io/badge/Cashfree-6933FF?style=for-the-badge&logoColor=white)
![PhonePe](https://img.shields.io/badge/PhonePe-5F259F?style=for-the-badge&logo=phonepe&logoColor=white)
![PayU](https://img.shields.io/badge/PayU-14AA4B?style=for-the-badge&logoColor=white)
![Square](https://img.shields.io/badge/Square-000000?style=for-the-badge&logo=square&logoColor=white)
![Airwallex](https://img.shields.io/badge/Airwallex-5A31F4?style=for-the-badge&logoColor=white)
![Google Pay](https://img.shields.io/badge/Google%20Pay-4285F4?style=for-the-badge&logo=googlepay&logoColor=white)
![Apple Pay](https://img.shields.io/badge/Apple%20Pay-000000?style=for-the-badge&logo=applepay&logoColor=white)

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

> Swap `payWithRazorpay` for `payWithStripe`, `payWithPaypal`, `payWithGooglePay`, … every gateway still returns the same `PaymentResult`, while some hosted/native sheets also need a `BuildContext`.

<div align="center">

**[Why this exists](#why-this-exists)** · **[Gateways](#gateways)** · **[Install](#install)** · **[Core types](#core-types)** · **[Cookbook](#per-gateway-cookbook)** · **[Demo app](#demo-app)** · **[Security](#security-notes)**

</div>

---

## Why this exists

Thirteen gateway SDKs ship thirteen call shapes, thirteen response objects, thirteen ways the user can cancel. Even when you wrap them, "user closed the sheet" usually disappears into a generic catch.

Uni Payments replaces all of that with a single sealed result type that the **Dart compiler forces you to exhaust** — every `switch` you write is checked at compile time, so you can't forget the cancel case again.

| | Before | With Uni Payments |
| --- | --- | --- |
| API per gateway | Different class, different callbacks, different error shape | `UniPayments.payWith*(...)` everywhere |
| Cancellation | Hidden inside `catch (e)` or a stringy status | `PaymentCancelled` — a real type |
| Verification | Dig through gateway-specific JSON | `result.transactionId` + `result.rawResponse` |
| Native setup | 13 different setup guides | Documented per gateway here |

---

## Gateways

| Gateway | Region | SDK | Imperative call | Native button |
| --- | --- | --- | --- | --- |
| ![Razorpay](https://img.shields.io/badge/Razorpay-3395FF?style=flat-square&logo=razorpay&logoColor=white) | India | `razorpay_flutter` | `payWithRazorpay` | — |
| ![Stripe](https://img.shields.io/badge/Stripe-635BFF?style=flat-square&logo=stripe&logoColor=white) | Global | `flutter_stripe` | `payWithStripe` | — |
| ![PayPal](https://img.shields.io/badge/PayPal-00457C?style=flat-square&logo=paypal&logoColor=white) | Global | `braintree_flutter_plus` | `payWithPaypal` | — |
| ![Paystack](https://img.shields.io/badge/Paystack-00C3F7?style=flat-square&logoColor=white) | Africa | `flutter_paystack_max` | `payWithPaystack` | — |
| ![Flutterwave](https://img.shields.io/badge/Flutterwave-FB6020?style=flat-square&logoColor=white) | Africa | `flutterwave_standard` | `payWithFlutterwave` | — |
| ![Paytm](https://img.shields.io/badge/Paytm-00BAF2?style=flat-square&logo=paytm&logoColor=white) | India | `paytmpayments_allinonesdk` | `payWithPaytm` | — |
| ![Cashfree](https://img.shields.io/badge/Cashfree-6933FF?style=flat-square&logoColor=white) | India | `flutter_cashfree_pg_sdk` | `payWithCashfree` | — |
| ![PhonePe](https://img.shields.io/badge/PhonePe-5F259F?style=flat-square&logo=phonepe&logoColor=white) | India · UPI | `phonepe_payment_sdk` | `payWithPhonepe` | — |
| ![PayU](https://img.shields.io/badge/PayU-14AA4B?style=flat-square&logoColor=white) | India · LatAm · Turkey · CEE | `payu_checkoutpro_flutter` | `payWithPayu` | — |
| ![Square](https://img.shields.io/badge/Square-000000?style=flat-square&logo=square&logoColor=white) | US · UK · CA · AU | `square_in_app_payments` | `payWithSquare` | — |
| ![Airwallex](https://img.shields.io/badge/Airwallex-5A31F4?style=flat-square&logoColor=white) | Global · APAC-strong | `airwallex_payment_flutter` | `payWithAirwallex` | — |
| ![Google Pay](https://img.shields.io/badge/Google%20Pay-4285F4?style=flat-square&logo=googlepay&logoColor=white) | Android | `pay` | `payWithGooglePay` | `googlePayButton(...)` |
| ![Apple Pay](https://img.shields.io/badge/Apple%20Pay-000000?style=flat-square&logo=applepay&logoColor=white) | iOS | `pay` | `payWithApplePay` | `applePayButton(...)` |

Every imperative call returns `Future<PaymentResult>`. Wallet buttons exist because Google + Apple's brand guidelines require their own button design.

---

## Install

```yaml
dependencies:
  uni_payments: ^0.0.9
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
| Flutter  | **3.41+** · Dart **3.8+** (required for `flutter_stripe` 14.x)                           |
| Android  | **`minSdkVersion 23`** — modern Stripe / Razorpay / PhonePe builds need it. **28+** if you use Square. |
| iOS      | **iOS 16+** — required by `braintree_flutter_plus` 7.x and compatible with the other SDKs |

### Required extra setup

<details>
<summary><b>Square needs a higher Android minSdkVersion</b></summary>

Square's In-App Payments SDK requires `minSdkVersion 28` (Android 9). `minSdkVersion` is a single app-wide setting, so if you use `payWithSquare`, raise it in your app's `android/app/build.gradle.kts`:

```kotlin
android {
  defaultConfig {
    minSdk = 28
  }
}
```

Skip this if you're not using Square — every other gateway in this package works down to `minSdkVersion 23`.

</details>

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
<summary><img src="https://img.shields.io/badge/Razorpay-3395FF?style=flat-square&logo=razorpay&logoColor=white" height="20" alt="Razorpay"/> &nbsp;<b>Razorpay</b></summary>

```dart
final result = await UniPayments.payWithRazorpay(
  keyId: 'YOUR_RAZORPAY_KEY_ID',
  amount: 25.00,                    // major units (₹25.00)
  businessName: 'Acme Inc',         // merchant header inside the sheet
  customer: customer,
  description: 'Pro subscription',
  themeColor: Colors.indigo,        // Color, not '#RRGGBB'
  currency: 'INR',
  timeout: const Duration(minutes: 5), // optional — see below
);
```

> By default this waits indefinitely for the checkout to complete. Pass
> `timeout` to get a `PaymentFailure` instead of hanging forever if the
> SDK never calls back (e.g. the app was backgrounded and killed).

</details>

<details>
<summary><img src="https://img.shields.io/badge/Stripe-635BFF?style=flat-square&logo=stripe&logoColor=white" height="20" alt="Stripe"/> &nbsp;<b>Stripe</b></summary>

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
<summary><img src="https://img.shields.io/badge/PayPal-00457C?style=flat-square&logo=paypal&logoColor=white" height="20" alt="PayPal"/> &nbsp;<b>PayPal</b> (Braintree drop-in)</summary>

```dart
final result = await UniPayments.payWithPaypal(
  context: context,
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
<summary><img src="https://img.shields.io/badge/Paystack-00C3F7?style=flat-square&logoColor=white" height="20" alt="Paystack"/> &nbsp;<b>Paystack</b></summary>

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
<summary><img src="https://img.shields.io/badge/Flutterwave-FB6020?style=flat-square&logoColor=white" height="20" alt="Flutterwave"/> &nbsp;<b>Flutterwave</b></summary>

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
<summary><img src="https://img.shields.io/badge/Paytm-00BAF2?style=flat-square&logo=paytm&logoColor=white" height="20" alt="Paytm"/> &nbsp;<b>Paytm</b></summary>

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
<summary><img src="https://img.shields.io/badge/Cashfree-6933FF?style=flat-square&logoColor=white" height="20" alt="Cashfree"/> &nbsp;<b>Cashfree</b></summary>

```dart
// orderId + paymentSessionId come from your backend's call to the
// Cashfree Orders API.
final result = await UniPayments.payWithCashfree(
  orderId: 'order_${DateTime.now().millisecondsSinceEpoch}',
  paymentSessionId: 'session_xxx',
  useStagingEnvironment: true,
  timeout: const Duration(minutes: 5), // optional, see below
);
```

> Only one Cashfree payment can be in flight at a time — the upstream SDK
> is a process-wide singleton. Calling this again before a prior call
> resolves fails fast with `PaymentFailure(errorCode:
> 'cashfree_already_in_progress')` instead of corrupting the first call.
> `timeout` works the same way as Razorpay's above.

</details>

<details>
<summary><img src="https://img.shields.io/badge/PhonePe-5F259F?style=flat-square&logo=phonepe&logoColor=white" height="20" alt="PhonePe"/> &nbsp;<b>PhonePe</b></summary>

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
<summary><img src="https://img.shields.io/badge/PayU-14AA4B?style=flat-square&logoColor=white" height="20" alt="PayU"/> &nbsp;<b>PayU</b></summary>

```dart
// Backend hands you a hash for every step PayU asks you to sign — see
// https://devguide.payu.in/flutter-sdk-integration/. Never compute this
// with the salt on-device.
Future<Map<dynamic, dynamic>> generateHash(Map<dynamic, dynamic> request) async {
  final response = await yourBackend.post('/payu/hash', body: request);
  return response.data; // e.g. { hashName: 'computedHashValue' }
}

final result = await UniPayments.payWithPayu(
  merchantKey: 'YOUR_PAYU_MERCHANT_KEY',
  amount: 25.00,
  productInfo: 'Pro subscription',
  customer: customer,
  transactionId: 'txn_${DateTime.now().millisecondsSinceEpoch}',
  successUrl: 'https://acme.dev/payu/success',
  failureUrl: 'https://acme.dev/payu/failure',
  generateHash: generateHash,
  useStagingEnvironment: true,
);
```

> Advanced CheckoutPro options (SI/subscriptions, split payments, EMI, custom notes, …) go through the optional `additionalPaymentParams` / `checkoutConfig` maps, using PayU's raw keys from `payu_checkoutpro_flutter`'s `PayUConstantKeys`.

</details>

<details>
<summary><img src="https://img.shields.io/badge/Square-000000?style=flat-square&logo=square&logoColor=white" height="20" alt="Square"/> &nbsp;<b>Square</b></summary>

```dart
final result = await UniPayments.payWithSquare(
  applicationId: 'YOUR_SQUARE_APPLICATION_ID', // sandbox-sq0idb-... or sq0idp-...
);
```

> This only tokenizes a card into a one-time-use nonce — Square's mobile SDK doesn't charge cards itself. Send `result.transactionId` (the nonce) to your backend and charge it via [Square's Payments API](https://developer.squareup.com/docs/payments-api/take-payments). Sandbox vs. production is decided entirely by which `applicationId` you pass. Also requires `minSdkVersion 28` on Android — see [Required extra setup](#required-extra-setup).

</details>

<details>
<summary><img src="https://img.shields.io/badge/Airwallex-5A31F4?style=flat-square&logoColor=white" height="20" alt="Airwallex"/> &nbsp;<b>Airwallex</b></summary>

```dart
final result = await UniPayments.payWithAirwallex(
  clientSecret: 'YOUR_PAYMENT_INTENT_CLIENT_SECRET', // from your server
  paymentIntentId: 'YOUR_PAYMENT_INTENT_ID',
  amount: 25.00,
  currency: 'USD',
  countryCode: 'US',
  useStagingEnvironment: true,
);
```

> Presents Airwallex's full hosted payment sheet (cards, wallets, and local redirect methods, depending on what your account supports). A result of `errorCode: 'payment_in_progress'` means the payment was submitted but its outcome isn't confirmed yet — the same situation as Razorpay's external-wallet case — verify via your backend before fulfilling.

</details>

<details>
<summary><img src="https://img.shields.io/badge/Google%20Pay-4285F4?style=flat-square&logo=googlepay&logoColor=white" height="20" alt="Google Pay"/> &nbsp;<b>Google Pay</b></summary>

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
<summary><img src="https://img.shields.io/badge/Apple%20Pay-000000?style=flat-square&logo=applepay&logoColor=white" height="20" alt="Apple Pay"/> &nbsp;<b>Apple Pay</b></summary>

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

The repo ships a fully-styled demo with all thirteen gateways wired up — animated gradient background, glass-morphism tiles, error toasts, haptic feedback on each outcome.

```sh
git clone https://github.com/NehilKoshiya/uni_payments
cd uni_payments/example
flutter pub get
flutter run
```

---

## Security notes

**Secrets**

* Never ship secret/private keys in your app binary. `secretKey` (Paystack), the PayU merchant **salt**, and Stripe/Airwallex `clientSecret`s must be generated or held on your server — a decompiled APK/IPA hands over anything embedded in it.
* PayU signs every checkout step with an HMAC computed from your salt. This package never computes that hash — `payWithPayu`'s `generateHash` callback exists specifically so the salt stays server-side; don't be tempted to inline the hash logic on-device "just for testing."

**Verification**

* A client-side result is a claim, not a fact — the device can lie, crash mid-flow, or lose network after the charge actually succeeded. Always reconcile server-side before fulfilling an order:
  * **`PaymentSuccess`** — re-check with the gateway (fetch the payment/order by id, or wait for its webhook) before shipping anything.
  * **`PaymentFailure`** / **`PaymentCancelled`** — don't assume no money moved. Bank debits and UPI/wallet redirects can complete after the client already gave up; several gateways in this package surface that explicitly as a specific `errorCode` (e.g. `external_wallet_pending` from Razorpay, `payment_in_progress` from Airwallex, `cashfree_already_in_progress`) precisely so you don't silently treat "ambiguous" as "definitely unpaid."
* Where the gateway signs its response (Razorpay's `orderId`/`signature` in `rawResponse`, Paytm's checksum, PayU's hash), verify that signature server-side too — `rawResponse` carries the untouched payload specifically so your backend has something to check against, not just log.

**Reliability**

* Use a genuinely unique `reference` / `transactionRef` / `orderId` / `transactionId` per attempt (not reused across retries) — every gateway that takes one uses it to detect duplicate charges on their end.
* `payWithRazorpay` and `payWithCashfree` accept an optional `timeout` — without one, a native SDK that never calls back (killed app, OEM quirk) leaves the `Future` pending forever with no way for your UI to recover.

**Dependencies**

* Every native SDK this package wraps is vetted for maintenance status before being added — see the [CHANGELOG](CHANGELOG.md) for two rejected candidates (a discontinued package, and one with a confirmed native-bridge bug) and the reasoning behind each. If you're auditing your own dependency tree, that's a good place to see the bar this package holds itself to.
* Keep `flutter_stripe` and the other native SDKs current — `dart pub outdated` should show no available upgrades left on the table; payment SDKs receive security-relevant patches (fraud signals, TLS/crypto updates) more often than most packages.

---

## Contributing

* Bug or feature request — [open an issue](https://github.com/NehilKoshiya/uni_payments/issues).
* Found this useful? A ⭐ on [GitHub](https://github.com/NehilKoshiya/uni_payments) goes a long way.

### Local setup

```sh
git clone https://github.com/NehilKoshiya/uni_payments
cd uni_payments
flutter pub get
flutter test
cd example && flutter pub get
```

### Before sending a PR

* `flutter analyze` must be clean. This package runs with `strict-casts`, `strict-inference` and `strict-raw-types` on top of `flutter_lints` (see [analysis_options.yaml](analysis_options.yaml)) — code that's merely "lint-clean" elsewhere may still fail here.
* `flutter test` must pass.
* Update [CHANGELOG.md](CHANGELOG.md) under a new version heading describing what changed and why — not just what.
* If your PR touches the example app, run it once (`cd example && flutter run`) and exercise the affected gateway's tile before opening the PR — analysis and tests don't catch a broken demo wiring.

### Adding a new gateway

Every gateway in this package follows the same shape, so a new one is mostly mechanical:

1. **`lib/src/gateways/<name>_gateway.dart`** — a stateless `<Name>Gateway` class with a `pay(...)` method that awaits/wraps the upstream SDK and maps its outcome onto `PaymentSuccess` / `PaymentFailure` / `PaymentCancelled`. Give it a `const _gatewayName = '<name>';` matching the public method name, and stash the untouched upstream response in `rawResponse` wherever you can.
2. **`lib/src/uni_payments.dart`** — add a `payWithXxx(...)` static method that validates required fields via `_validate(...)` and delegates to the new gateway. Document any upstream quirks in the doc comment (see `payWithCashfree` for an example of calling out an upstream concurrency limitation).
3. **`pubspec.yaml`** — add the dependency, and check its `environment:` constraint before pinning — don't silently raise this package's Flutter/Dart floor for an optional gateway (see the `square_in_app_payments` comment for the pattern).
4. **`example/`** — add a tile (`lib/data/gateway.dart`), a demo method (`lib/services/payment_demos.dart`), wire it into the dispatch map (`lib/ui/home_screen.dart`), and add a brand color/letter fallback (`lib/ui/brand_icon.dart`) if [Simple Icons](https://simpleicons.org) doesn't have the logo.
5. **`README.md`** — add a row to the [Gateways](#gateways) table and a cookbook entry under [Per-gateway cookbook](#per-gateway-cookbook).
6. **`CHANGELOG.md`** — new gateways get their own entry under "New gateways."

Before proposing a gateway, do the same vetting this package already applies: check pub.dev for maintenance status (points, likes, **last published date**, and whether it's marked discontinued), and skim the native bridge source for obvious gaps (does every outcome — including cancellation — actually reach Dart?). Two candidates were rejected for exactly these reasons; see the CHANGELOG.

<br>

<div align="center">

[![GitHub stars](https://img.shields.io/github/stars/NehilKoshiya/uni_payments?style=social)](https://github.com/NehilKoshiya/uni_payments)
[![GitHub issues](https://img.shields.io/github/issues/NehilKoshiya/uni_payments?color=blueviolet)](https://github.com/NehilKoshiya/uni_payments/issues)

**MIT** · © Nehil Koshiya

</div>
