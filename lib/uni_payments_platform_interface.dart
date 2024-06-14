import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'uni_payments_method_channel.dart';

abstract class UniPaymentsPlatform extends PlatformInterface {
  /// Constructs a UniPaymentsPlatform.
  UniPaymentsPlatform() : super(token: _token);

  static final Object _token = Object();

  static UniPaymentsPlatform _instance = MethodChannelUniPayments();

  /// The default instance of [UniPaymentsPlatform] to use.
  ///
  /// Defaults to [MethodChannelUniPayments].
  static UniPaymentsPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [UniPaymentsPlatform] when
  /// they register themselves.
  static set instance(UniPaymentsPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
