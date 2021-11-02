import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uni_payments/uni_payments.dart';

void main() {
  const MethodChannel channel = MethodChannel('uni_payments');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });
}
