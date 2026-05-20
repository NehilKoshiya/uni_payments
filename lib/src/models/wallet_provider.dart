/// A digital-wallet provider exposed through `UniPayments.googlePay` /
/// `UniPayments.applePay` and the matching button builders.
enum WalletProvider {
  /// Google Pay (Android).
  googlePay,

  /// Apple Pay (iOS).
  applePay,
}
