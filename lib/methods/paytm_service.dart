import 'dart:io';

import 'package:paytm_allinonesdk/paytm_allinonesdk.dart';
import '../uni_payments.dart';

class PaytmService {
  /// open paytm payments gateway
  openPaytm({
    required String paytmMerchantId,
    required String orderId,
    required String uniqueTransactionToken,
    required bool isStaging,
    required double amount,
    required Function(UniPaymentResponse) successListener,
    required Function(UniPaymentResponse) failureListener,
  }) {
    /// set the development env for managing payments
    String callBackURL = isStaging
        ? "https://securegw-stage.paytm.in/theia/paytmCallback?ORDER_ID=$orderId"
        : "https://securegw.paytm.in/theia/paytmCallback?ORDER_ID=$orderId";

    /// initiate transaction
    var response = AllInOneSdk.startTransaction(
        paytmMerchantId,
        orderId,
        amount.toString(),
        uniqueTransactionToken,
        callBackURL,
        isStaging,
        true);

    response.then((value) {
      if (Platform.isAndroid) {
        /// Registers event listeners for payment success events
        successListener(
          UniPaymentResponse(
            value.toString(),
            value!['STATUS'],
            value['TXNID'],
          ),
        );
      } else {
        /// Registers event listeners for payment failures events
        successListener(
          UniPaymentResponse(
            value.toString(),
            value!['response']['STATUS'],
            value['response']['TXNID'],
          ),
        );
      }
    }).catchError((onError) {
      /// Registers event listeners for payment failures events
      failureListener(
        UniPaymentResponse(
          "${onError.message.toString()} ${onError.details.toString()}",
          false,
          "TXN_FAIL",
        ),
      );
    });
  }
}
