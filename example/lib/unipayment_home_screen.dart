import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uni_payments/uni_payments.dart';

import 'services/services.dart';

class UniPaymentsHomeScreen extends StatefulWidget {
  const UniPaymentsHomeScreen({super.key});

  @override
  State<UniPaymentsHomeScreen> createState() => _UniPaymentsHomeScreenState();
}

class _UniPaymentsHomeScreenState extends State<UniPaymentsHomeScreen> {
  String googlePayJsonString = '';

  @override
  void initState() {
    loadJSONStringFromAsset();
    super.initState();
  }

  loadJSONStringFromAsset() async {
    googlePayJsonString = await rootBundle.loadString("assets/json/gpay.json");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            color: Colors.blue,
            padding:
                EdgeInsets.only(top: MediaQuery.of(context).size.height / 14),
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Text(
              "Universal Payment".toUpperCase(),
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  letterSpacing: 2.5,
                  decorationStyle: TextDecorationStyle.dashed),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(22),
                topRight: Radius.circular(22),
              ),
            ),
            height: MediaQuery.of(context).size.height / 1.2,
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    customRowWithPaymentCard(
                      imagePath: 'assets/images/paytm.png',
                      imagePath2: 'assets/images/paystack.png',
                      onTap: () async {
                        await Services().paytmService();
                      },
                      onTap2: () async {
                        await Services().payStackService(context: context);
                      },
                    ),
                    customRowWithPaymentCard(
                      imagePath: 'assets/images/razorpay.png',
                      imagePath2: 'assets/images/paypal.png',
                      onTap: () async {
                        await Services().callRazorPayService();
                      },
                      onTap2: () async {
                        await Services().callBraintreePaypalService();
                      },
                    ),
                    customRowWithPaymentCard(
                      imagePath: 'assets/images/flutterwave.png',
                      imagePath2: 'assets/images/gpay.png',
                      onTap: () async {
                        await Services().flutterWaveService(context: context);
                      },
                      onTap2: () {},
                    ),
                    googlePayJsonString.isEmpty
                        ? CircularProgressIndicator()
                        : UniPayments.uniPaymentGooglePayButton(
                            paymentConfigurationAsset: googlePayJsonString,
                            height: 150,
                            uniPaymentItemStatus: UniPaymentItemStatus.pending,
                            uniPaymentItemTypes: UniPaymentItemTypes.item,
                            payableAmount: "ENTER_AMOUNT_HERE",
                            uniPaymentGoogleButtonStyle:
                                UniPaymentGoogleButtonStyle.flat,
                            uniPaymentGoogleButtonType:
                                UniPaymentGoogleButtonType.donate,
                            paymentLabel: "ENTER_LABLE_PAYMENT",
                            failureListener:
                                (UniPaymentResponse paymentResponse) {},
                            successListener:
                                (UniPaymentResponse paymentResponse) {},
                            onPressed: () {
                              print("Universal Google Pay Button Pressed");
                            },
                          ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  customRowWithPaymentCard({
    required String imagePath,
    required Function() onTap,
    required String imagePath2,
    required Function() onTap2,
  }) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            onTap: onTap,
            child: Container(
              height: 160,
              width: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 5,
                    offset: Offset(4, 6),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(imagePath),
            ),
          ),
          SizedBox(
            width: 18,
          ),
          InkWell(
            onTap: onTap2,
            child: Container(
              height: 160,
              width: 160,
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 5,
                    offset: Offset(4, 6),
                  ),
                ],
              ),
              child: Image.asset(imagePath2),
            ),
          ),
        ],
      ),
    );
  }
}
