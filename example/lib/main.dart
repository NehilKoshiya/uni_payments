import 'package:flutter/material.dart';
import 'package:uni_payments/uni_payments.dart';
import 'package:uni_payments_example/helpers/helpers.dart';
import 'package:uni_payments_example/services/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        key: _scaffoldkey,
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.0,
        ),
        body: Column(
          children: [
            Helpers().titleText(),
            Helpers().sizedBox(20.0, 0.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () async {
                    await Services().callRazorPayService(_scaffoldkey);
                  },
                  child: Container(
                    height: 150,
                    width: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          blurRadius: 7,
                          offset: Offset(4, 6),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset("assets/images/razorpay.png"),
                  ),
                ),
                SizedBox(
                  width: 15,
                ),
                InkWell(
                  onTap: () async {
                    UniPaymentResponse uniPaymentResponse =
                        await Services().callPayStackService(context: context);

                    if (uniPaymentResponse.paymentStatus) {
                      Helpers().snackBar(
                          _scaffoldkey, true, "Paystack Payment Success");
                    } else {
                      Helpers().snackBar(
                          _scaffoldkey, false, "Paystack Payment Failure");
                    }
                  },
                  child: Container(
                    height: 150,
                    width: 150,
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          blurRadius: 7,
                          offset: Offset(4, 6),
                        ),
                      ],
                    ),
                    child: Image.asset("assets/images/paystack.png"),
                  ),
                ),
              ],
            ),
            Helpers().sizedBox(20.0, 0.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () async {
                    await Services().callPayTmService(_scaffoldkey);
                  },
                  child: Container(
                    height: 150,
                    width: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          blurRadius: 7,
                          offset: Offset(4, 6),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset("assets/images/paytm.png"),
                  ),
                ),
                SizedBox(
                  width: 15,
                ),
                InkWell(
                  onTap: () async {
                    await Services().callFlutterWaveService(
                      context: context,
                      key: _scaffoldkey,
                    );
                  },
                  child: Container(
                    height: 150,
                    width: 150,
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          blurRadius: 7,
                          offset: Offset(4, 6),
                        ),
                      ],
                    ),
                    child: Image.asset("assets/images/flutterwave.png"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
