# Uni Payments
A Flutter plugin for making payments via different payment methods for accepting online payments in Flutter app.
<br>
## Available Payment Methods

✅ &nbsp; Razorpay </br>
✅ &nbsp; Paystack</br>
✅ &nbsp; FlutterWave</br>
✅ &nbsp; Paytm</br>
✅ &nbsp; GooglePay
<br>
<br>

| Razorpay                                                                                        | Paystack                                                                                        |
| ----------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------- |
| ![](https://github.com/NehilKoshiya/uni_payments/raw/master/example/assets/readme/razorpay.gif) | ![](https://github.com/NehilKoshiya/uni_payments/raw/master/example/assets/readme/paystack.gif) |

<br>
<br>

| Paytm                                                                                        | Flutter wave                                                                                       |
| -------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------- |
| ![](https://github.com/NehilKoshiya/uni_payments/raw/master/example/assets/readme/paytm.gif) | ![](https://github.com/NehilKoshiya/uni_payments/raw/master/example/assets/readme/flutterwave.gif) |

<br> 
<br>

| GooglePay                                                                                                   |
| ----------------------------------------------------------------------------------------------------------- |
| ![](https://raw.githubusercontent.com/NehilKoshiya/uni_payments/master/example/assets/readme/googlepay.gif) |

<br>

## :rocket: Installation

This plugin is available on Pub: [https://pub.dev/packages/uni_payments](https://pub.dev/packages/razorpay_flutter)

Add this to `dependencies` in your app's `pubspec.yaml`

```yaml
uni_payments : latest_version
```

## :bookmark: Usage

Sample code to integrate can be found in [example/lib/main.dart](example/lib/main.dart).

#### Integrate Razorpay Payment Gateway

```dart
 await UniPayments.razorPayPayment(
      razorpayKey: "ENTER_RAZORPAY_KEY",
      contactNumber: "ENTER_MOBILE_NUMBER",
      emailId: "ENTER_EMAIL_ID",
      amount: 2500,
      userName: "ENTER_USER_NAME",
      successListener: (UniPaymentResponse uniPaymentResponse) {
        /// here manage code for success payment. ///
        if (uniPaymentResponse.paymentStatus) {
          /// perform action on success here ///
        }
      },
      failureListener: (UniPaymentResponse uniPaymentResponse) {
        /// here manage code for failure or error in payment. ///
        if (uniPaymentResponse.paymentStatus) {
          /// perform action on failure here ///
        }
      },
    );
```

#### Integrate Paystack Payment Gateway

```dart
 UniPaymentResponse uniPaymentResponse = await PayStackService().openPaystackWithCard(
      context: context,
      emailId: "ENTER_EMAIL_ID",
      payStackKey: 'ENTER_PAYSTACK_KEY_HERE',
      amount: 2500,
    );
  if (uniPaymentResponse.paymentStatus) {
    /// perform action on success here ///
  } 
```

#### Integrate Paytm Payment Gateway

```dart
 UniPayments.paytmPayment(
      baseUrl: "ENTER_BASE_URL_FROM_BACKEND",
      bodyParameter: {
        /// Enter map of bodyparameter ///
      },
      headers: {
        /// Enter map of headers ///
      },
      paytmMerchantId: "ENTER_PAYTM_MERCHENT_ID",
      orderId: "ENTER_ORDER_ID",
      isTesting: true,
      amount: 2500,
      successListener: (UniPaymentResponse uniPaymentResponse) {
        /// here manage code for success payment. ///
        if (uniPaymentResponse.paymentStatus) {
          /// perform action on success here ///
        }
      },
      failureListener: (UniPaymentResponse uniPaymentResponse) {
        /// here manage code for failure or error in payment. ///
        if (uniPaymentResponse.paymentStatus) {
          /// perform action on failure here ///
        }
      },
    );
```

#### Integrate Flutterwave Payment Gateway

```dart
 await UniPayments.flutterWavePayment(
      buildContext: context,
      publicKey: 'ENTER_PUBLIC_KEY_HERE',
      encryptionKey: 'ENTER_ENCRYPTION_KEY',
      currencyCode: 'NGN',
      amount: '2500',
      receiptantName: 'ENTER_USER_NAME',
      emailId: 'ENTER_EMAIL_ID',
      phoneNumber: 'ENTER_CONTACT_NUMBER',
      isDebugMode: true,
      acceptCardPayment: true,
      successListener: (UniPaymentResponse uniPaymentResponse) {
        /// here manage code for success payment. ///
        if (uniPaymentResponse.paymentStatus) {
          /// perform action on success here ///
        }
      },
      failureListener: (UniPaymentResponse uniPaymentResponse) {
        /// here manage code for failure or error in payment. ///
        if (uniPaymentResponse.paymentStatus) {
          /// perform action on failure here /// 
        }
      },
    );
```
#### Integrate Googlepay Payment Gateway
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
***

### :heart:  Found this project useful?

If you found this project useful, then please consider giving it a :star:  on Github and sharing it with your friends via social media.

The project is open to public contribution. Please feel very free to contribute.
Experienced an issue or want to report a bug? Please, [report it here](https://github.com/NehilKoshiya/uni_payments/issues). Remember to be as descriptive as possible.

---


