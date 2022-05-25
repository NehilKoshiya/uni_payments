import 'dart:convert';
import 'package:http/http.dart';

import 'package:paytm/paytm.dart';
import '../uni_payments.dart';

class PaytmService {
  openPaytm({
    required String baseUrl,
    required Map<String, String> headers,
    required Map<String, String> body,
    required String paytmMerchantId,
    required String orderId,
    required bool isTesting,
    required double amount,
    required Function(UniPaymentResponse) successListener,
    required Function(UniPaymentResponse) failureListener,
  }) async {
    // storing messages here
    String? paymentResponse;

    /// managing callBackUrl Here
    String callBackUrl = (isTesting
            ? 'https://securegw-stage.paytm.in'
            : 'https://securegw.paytm.in') +
        '/theia/paytmCallback?ORDER_ID=' +
        orderId;

    try {
      /// call api for getting response.
      final response = await post(
        Uri.parse(baseUrl),
        body: body,
        headers: headers,
      );

      /// convert response in readable data.
      var getdata = json.decode(response.body);

      /// return if any error in API or not.
      bool error = getdata["error"];

      if (!error) {
        String txnToken = getdata["txn_token"];

        /// for getting response of transaction.
        var paytmResponse = Paytm.payWithPaytm(
            mId: paytmMerchantId,
            orderId: orderId,
            txnToken: txnToken,
            txnAmount: amount.toString(),
            callBackUrl: callBackUrl,
            staging: isTesting);

        paytmResponse.then((value) {
          if (value['error']) {
            paymentResponse = value['errorMessage'];

            /// return failure event with errorMessage and status.
            failureListener(
                UniPaymentResponse(value['errorMessage'], false, "TXN_FAIL"));
          } else {
            if (value['response'] != null) {
              paymentResponse = value['response']['STATUS'];
              if (paymentResponse == "TXN_SUCCESS") {
                /// return Success event with successMessage and status.
                successListener(
                  UniPaymentResponse(
                    value['response']['STATUS'],
                    true,
                    value['response']['TXNID'],
                  ),
                );
              } else {
                /// return Success event with successMessage and status.
                successListener(
                  UniPaymentResponse(
                    value['response']['STATUS'],
                    true,
                    value['response']['TXNID'],
                  ),
                );
              }
            }
          }
        });
      } else {
        ///  found any error at start return this listner.
        failureListener(
          UniPaymentResponse(
            "Transaction cancel by user",
            false,
            "TXN_FAIL",
          ),
        );
      }
    } catch (e) {
      // for caching error with errormessage
      failureListener(
        UniPaymentResponse(
          e.toString(),
          false,
          "TXN_FAIL",
        ),
      );
    }
  }
}
