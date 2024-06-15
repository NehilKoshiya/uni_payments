<h1 align="center">
   <img src="https://raw.githubusercontent.com/NehilKoshiya/uni_payments/master/example/assets/readme/readmE.png" alt="Uni Payments" title="Logo" />
  <br>
</h1>

<p align="center">  
  <a href="https://app.codacy.com/gh/NehilKoshiya/uni_payments/dashboard?utm_source=gh&utm_medium=referral&utm_content=&utm_campaign=Badge_grade"><img src="https://app.codacy.com/project/badge/Grade/e0a2010154234e58af879792515f97ba"/>
  </a>
  <a href="https://pub.dev/packages/uni_payments"> <img height="20" alt="Pub" src="https://img.shields.io/pub/v/uni_payments.svg?style=for-the-badge">
  </a>
  <a href="https://github.com/NehilKoshiya/uni_payments/blob/master/LICENSE"><img src="https://img.shields.io/badge/license-APACHE2.0-blue.svg?longCache=true&style=flat-square">
  </a>
  <a href="https://flutter.dev"><img src="https://img.shields.io/badge/Built%20for-Flutter-blue.svg?longCache=true&style=flat-square" ">

  <a href="https://codecov.io/github/NehilKoshiya/uni_payments">
  <img src="https://codecov.io/github/NehilKoshiya/uni_payments/graph/badge.svg?token=LSBOWQO21S"/>
  </a>
</p>

<p align="center">  
Uni Payments offers seamless integration for multiple payment gateways including <strong> Razorpay, Flutterwave, Google Pay, Paytm, Paystack, and PayPal </strong> ensuring a fast, easy and secure transaction process.
</p>

<h1 align="center">

   <img src="https://github.com/NehilKoshiya/uni_payments/raw/master/example/assets/readme/paytm.gif" alt="Uni Payments" title="Logo" />
  <br>
</h1>

# Getting Started

- Add this to your pubspec.yaml
  ```
  dependencies:
  uni_payments: <latest_version>
  ```
- Get the package from Pub:

  ```
  flutter pub get
  ```

- Import it in your file

  ```
  import 'package:uni_payments/uni_payments.dart';
  ```

## Usage

- Check out the complete example with integration and declarations [uni_payments_example](https://github.com/NehilKoshiya/uni_payments/blob/master/example/)

## Razorpay

```dart
 await UniPayments.razorPayPayment(
      razorpayKey: "add_razopay_key",
      contactNumber: "1234567890",
      emailId: "add_email_id",
      amount: 2500,
      userName: "uni_payments",
      colorCode: '#fcba03',
      description: 'Add the description for the order or payment.',
      successListener: (UniPaymentResponse uniPaymentResponse) {
        /// here manage code for success payment.
        bool isSuccessPayment = uniPaymentResponse.paymentStatus;
        if (isSuccessPayment) {
          log(uniPaymentResponse.message);
          log(uniPaymentResponse.paymentId);
        }
      },
      failureListener: (UniPaymentResponse uniPaymentResponse) {
        /// here manage code for failure or error in payment.
        bool isFailedPayment = uniPaymentResponse.paymentStatus;
        if (isFailedPayment) {
          log(uniPaymentResponse.message);
          log(uniPaymentResponse.paymentId);
        }
      },
    );
```

## Paystack

```dart
    UniPaymentResponse uniPaymentResponse = await UniPayments.payStackPayment(
      context: context,
      emailId: "test@gmail.com",
      payStackKey: 'enter_paystack_key',
      amount: 2500,
      uniqueRefrenceID: 'enter_unique_transaction_key',
      callbackUrl: 'callback_url_for_transaction_response',
    );
```

## Paytm

```dart
await UniPayments.paytmPayment(
      /// Login to "dashboard.paytm.com" with your Paytm account details & Get Merchant Id.
      paytmMerchantId: "paytm_merchant_id",
      orderId: "order_id",
      isStaging: true,
      uniqueTransactionToken: "unique_id_database_refrences",
      amount: 2500,
      successListener: (UniPaymentResponse uniPaymentResponse) {
        /// here manage code for success payment.
        bool isSuccessPayment = uniPaymentResponse.paymentStatus;
        if (isSuccessPayment) {
          log(uniPaymentResponse.message);
          log(uniPaymentResponse.paymentId);
        }
      },
      failureListener: (UniPaymentResponse uniPaymentResponse) {
        /// here manage code for failure or error in payment.
        bool isFailedPayment = uniPaymentResponse.paymentStatus;
        if (isFailedPayment) {
          log(uniPaymentResponse.message);
          log(uniPaymentResponse.paymentId);
        }
      },
    );
```

## Flutterwave

```dart
  await UniPayments.flutterWavePayment(
      buildContext: context,
      publicKey: 'add_public_ke',
      encryptionKey: 'add_encryption_key',
      currencyCode: 'NGN',
      amount: '2500',
      receiptantName: 'Test User',
      emailId: 'test@gmail.com',
      phoneNumber: '1234567890',
      isDebugMode: true,
      redirectURL: 'add-redirect-url-here',
      transactionRef: 'add-random-string-everytime-transaction-refrence',
      successListener: (UniPaymentResponse uniPaymentResponse) {
        /// here manage code for success payment.
        bool isSuccessPayment = uniPaymentResponse.paymentStatus;
        if (isSuccessPayment) {
          log(uniPaymentResponse.message);
          log(uniPaymentResponse.paymentId);
        }
      },
      failureListener: (UniPaymentResponse uniPaymentResponse) {
        /// here manage code for failure or error in payment.
        bool isFailedPayment = uniPaymentResponse.paymentStatus;
        if (isFailedPayment) {
          log(uniPaymentResponse.message);
          log(uniPaymentResponse.paymentId);
        }
      },
    );
```

## Googlepay

```dart
UniPayments.uniPaymentGooglePayButton(
                      paymentConfigurationAsset: 'ENTER_ASSET_PATH',
                      height: 150,
                      width: 150,
                      uniPaymentItemStatus: UniPaymentItemStatus.pending,
                      uniPaymentItemTypes: UniPaymentItemTypes.item,
                      payableAmount: "ENTER_AMOUNT_HERE",
                      uniPaymentGoogleButtonStyle:
                          UniPaymentGoogleButtonStyle.flat,
                      uniPaymentGoogleButtonType:
                          UniPaymentGoogleButtonType.donate,
                      paymentLabel: "ENTER_LABLE_PAYMENT",
                      failureListener: (UniPaymentResponse paymentResponse) {
                        /// here manage code for failure or error in payment. ///
                      },
                      successListener: (UniPaymentResponse paymentResponse) {
                        /// here manage code for failure or error in payment. ///
                      },
                      onPressed: () {
                        print("Universal Google Pay Button Pressed");
                      },
                    ),
```

## Paypal Braintree

```dart
 UniPaymentResponse uniPaymentResponse =
        await UniPayments.payPalBraintreePayment(
            tokenizationKey: "enter_key_braintree_paypal",
            amount: 5200,
            emailId: 'test@gmail.com',
            name: 'uni payments',
            countryCode: 'US',
            currencyCode: 'USD');

```

## Found this package useful?

If you found this project useful, then please consider giving it a :star: on Github and sharing it with your friends via social media. [Give a Star](https://github.com/NehilKoshiya/uni_payments/).

Contributions are welcome! Feel free to submit a pull request or open an issue for any feature requests or bugs, [Create a Ticket](https://github.com/NehilKoshiya/uni_payments/issues).
