import 'package:flutter_test/flutter_test.dart';

import 'package:uni_payments_example/main.dart';

void main() {
  testWidgets('UniPaymentsDemoApp boots with the brand title', (tester) async {
    await tester.pumpWidget(const UniPaymentsDemoApp());
    // The home screen has an infinitely repeating gradient animation, so
    // `pumpAndSettle` would never return — pump a single frame instead.
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Uni Payments'), findsOneWidget);
  });
}
