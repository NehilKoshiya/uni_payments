import 'package:flutter_test/flutter_test.dart';
import 'package:uni_payments/uni_payments.dart';

void main() {
  group('PaymentResult', () {
    test('PaymentSuccess exposes transactionId + gatewayName', () {
      const result = PaymentSuccess(
        gatewayName: 'razorpay',
        transactionId: 'pay_abc123',
        message: 'ok',
      );
      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.isCancelled, isFalse);
      expect(result.transactionId, 'pay_abc123');
      expect(result.gatewayName, 'razorpay');
    });

    test('PaymentFailure carries errorCode + message + gatewayName', () {
      const result = PaymentFailure(
        gatewayName: 'stripe',
        errorCode: 'card_declined',
        message: 'Card was declined',
      );
      expect(result.isFailure, isTrue);
      expect(result.errorCode, 'card_declined');
      expect(result.gatewayName, 'stripe');
    });

    test('PaymentCancelled.isCancelled is true', () {
      const result = PaymentCancelled(
        gatewayName: 'paytm',
        message: 'User dismissed sheet',
      );
      expect(result.isCancelled, isTrue);
      expect(result.isSuccess, isFalse);
      expect(result.gatewayName, 'paytm');
    });

    test('exhaustive switch over PaymentResult compiles', () {
      const PaymentResult result = PaymentSuccess(
        gatewayName: 'razorpay',
        transactionId: 't',
      );
      final label = switch (result) {
        PaymentSuccess() => 'success',
        PaymentFailure() => 'failure',
        PaymentCancelled() => 'cancelled',
      };
      expect(label, 'success');
    });

    test('equality respects gatewayName', () {
      expect(
        const PaymentSuccess(transactionId: 'a', gatewayName: 'stripe'),
        const PaymentSuccess(transactionId: 'a', gatewayName: 'stripe'),
      );
      expect(
        const PaymentSuccess(transactionId: 'a', gatewayName: 'stripe'),
        isNot(
          const PaymentSuccess(transactionId: 'a', gatewayName: 'razorpay'),
        ),
      );
    });
  });

  group('UniCustomer', () {
    test('equality + hashCode work', () {
      const a = UniCustomer(name: 'A', email: 'a@x.com', phone: '999');
      const b = UniCustomer(name: 'A', email: 'a@x.com', phone: '999');
      const c = UniCustomer(name: 'A', email: 'a@x.com');
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(c));
    });
  });

  group('UniPayments input validation', () {
    test('rejects empty keyId + zero amount before hitting the SDK', () async {
      final result = await UniPayments.payWithRazorpay(
        keyId: '   ',
        amount: 0,
        businessName: 'X',
        customer: const UniCustomer(name: 'A', email: 'a@x.com'),
      );
      expect(result, isA<PaymentFailure>());
      expect((result as PaymentFailure).errorCode, 'invalid_input');
    });
  });
}
