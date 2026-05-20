## 0.0.6

### New gateways

* **Cashfree** (`UniPayments.payWithCashfree`) — India. Uses Cashfree's
  Web Checkout SDK (`flutter_cashfree_pg_sdk` ^2.3.4). Server-driven —
  pass an `orderId` + `paymentSessionId` from your backend.
* **PhonePe** (`UniPayments.payWithPhonepe`) — India / UPI. Uses the
  official `phonepe_payment_sdk` ^3.0.2. Server-driven — pass a
  base64-encoded request body assembled by your backend.

### Braintree → braintree_flutter_plus

* Switched the PayPal/Braintree integration from the abandoned
  `flutter_braintree` to the maintained fork `braintree_flutter_plus`
  ^5.2.1. API is identical; no consumer changes required.

### API naming polish

All methods, params and result fields were renamed for self-documenting,
IDE-discoverable consumption:

* **Methods** all prefix `payWith*` so `UniPayments.pay` lists every
  gateway in autocomplete:
  `payWithRazorpay`, `payWithStripe`, `payWithPaystack`,
  `payWithFlutterwave`, `payWithPaytm`, `payWithPaypal`,
  `payWithGooglePay`, `payWithApplePay`.
* `canUseWallet` → `isWalletSupported`.
* **Params** disambiguated:
  `key` → `keyId`, `name` (ambiguous) → `businessName`,
  `staging` → `useStagingEnvironment`, `country` → `countryCode`,
  `appleMerchantId` → `applePayMerchantId`,
  `paymentConfiguration` → `paymentConfigurationJson`,
  `label` → `lineItemLabel`, `itemStatus` → `lineItemStatus`,
  `itemType` → `lineItemType`.
* **`PaymentResult` fields** are now unambiguous on the consumer side:
  `code` → `errorCode`, `raw` → `rawResponse`, `gateway` → `gatewayName`.

### Developer experience

* **`UniCustomer` value class** — `name`, `email`, `phone` get passed once
  and reused across every gateway that prefills a checkout form, instead
  of being re-declared per-call.
* **`Color` (not hex string)** for `themeColor` — Razorpay accepts any
  Flutter `Color`; the gateway converts to Razorpay's `#RRGGBB` format
  internally.
* **Imperative wallets**: `UniPayments.googlePay(...)` and
  `UniPayments.applePay(...)` return `Future<PaymentResult>` just like
  every other gateway, so you can `await` them from a custom button.
  The native `googlePayButton` / `applePayButton` widgets are still there
  for when Google / Apple's UX guidelines require them.
* **`UniPayments.canUseWallet(WalletProvider.applePay, config)`** — probe
  whether the device actually supports a wallet before showing the
  button.
* **Gateway-aware results**: every `PaymentResult` is stamped with the
  originating `gateway` string (`razorpay`, `stripe`, `apple_pay`, ...)
  so consumers can branch by gateway without tracking it themselves.
* **Consistent naming sweep**: `keyId` (not `key`), `businessName` (not
  ambiguous `name`), `customer` (not separate `email`/`name`/`phone`),
  `staging` (not `isStaging`), `testMode` (not `isDebugMode`).

### Highlights

* Every gateway is now actually functional and validated against the
  upstream APIs of `razorpay_flutter` 1.4, `flutter_paystack_max` 1.0,
  `flutterwave_standard` 1.1, `paytm_allinonesdk` 1.2,
  `flutter_braintree` 4.0, `flutter_stripe` 12.6 and `pay` 3.3.
* Stripe PaymentSheet now wires up Apple Pay + Google Pay correctly via
  `applePayMerchantId` and `merchantCountryCode`.
* Razorpay external-wallet event is reported as a distinct
  `external_wallet_pending` failure code so you know to verify via webhook
  instead of treating it as paid.
* Paytm response is normalised across both Android and iOS flows
  (top-level vs. nested-under-`response`), and `RESPCODE 141` is mapped to
  `PaymentCancelled`.
* Every facade method input-validates non-empty keys + positive amount
  before hitting the native SDK.
* Wallet buttons no longer force `width`/`height` — they size themselves
  per Google/Apple guidelines (use `margin` and a `SizedBox` if needed).

### Breaking

* **Public API redesign.** Every gateway now returns
  `Future<PaymentResult>` — a sealed type with three cases
  (`PaymentSuccess`, `PaymentFailure`, `PaymentCancelled`). The old
  `UniPaymentResponse` + callback pattern has been removed.
* Renamed methods to drop the redundant `Payment` suffix:
  `razorPayPayment` → `razorpay`, `payStackPayment` → `paystack`,
  `paytmPayment` → `paytm`, `flutterWavePayment` → `flutterwave`,
  `payPalBraintreePayment` → `braintree`,
  `uniPaymentGooglePayButton` → `googlePayButton`.
* Renamed parameters: `receiptantName` → `name`,
  `uniqueRefrenceID` → `reference`, `emailId` → `email`,
  `colorCode` → `themeColor`, `isDebugMode` → `testMode`,
  `uniqueTransactionToken` → `txnToken`, `isStaging` → `staging`.
* Removed the unused `MethodChannel` / `PlatformInterface` scaffolding —
  this is a pure-Dart package now; the empty `android/` and `ios/`
  directories were deleted.
* Removed `flutter_web_plugins` and `plugin_platform_interface` deps.

### Added

* **Stripe** support via `flutter_stripe 12.6` and the PaymentSheet API.
* **Apple Pay** widget builder via `pay 3.3`.
* Strongly-typed `UniPaystackCurrency` enum (no upstream import needed).
* Cancellation is now a first-class outcome — switch over `PaymentResult`
  to handle it explicitly.
* Full `==` / `hashCode` / `toString` on every `PaymentResult` variant.

### Fixed

* PayPal/Braintree: inverted success/failure branches, null-deref crash on
  user cancellation.
* Paystack: `print(secretKey)` was leaking the secret to logs.
* Paytm: status field was being passed straight through as a `bool` even
  though it's a `String` like `TXN_SUCCESS`.
* Razorpay: instance was never `clear()`ed, leaking listeners on each call.
* Razorpay: amount is now correctly rounded to integer paise.
* All gateways: `BuildContext` is checked for `mounted` after async gaps.

### Changed

* Bumped SDK floor to Flutter 3.32 / Dart 3.8.
* Upgraded every dependency to its latest stable:
  * `razorpay_flutter` 1.3.7 → 1.4.5
  * `flutter_paystack_max` 1.0.4 → 1.0.6
  * `flutterwave_standard` 1.0.8 → 1.1.0 (constructor + `charge()` API)
  * `paytm_allinonesdk` 1.2.5 → 1.2.8
  * `pay` 2.0.0 → 3.3.0
  * `flutter_braintree` ^4.0.0
  * `flutter_stripe` ^12.6.0 *(new)*
* Strict analyzer settings (`strict-casts`, `strict-inference`,
  `strict-raw-types`) and `flutter_lints` 5.

### Example app

* Complete rewrite — Material 3, dark + light themes, animated gradient
  background, glass-morphism cards, responsive grid, live result card.

---

## 0.0.5

* Web platform removed due to unsupported SDKs.

## 0.0.4

* Solve Pub Analytics Issues.

## 0.0.3

* Major Version Update - PayPal Added.

## 0.0.2

* Google Pay Integration.

## 0.0.1

* Initial Release.
