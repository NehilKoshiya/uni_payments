import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'uni_payments_platform_interface.dart';

/// An implementation of [UniPaymentsPlatform] that uses method channels.
class MethodChannelUniPayments extends UniPaymentsPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('uni_payments');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
