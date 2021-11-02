/// [UniPaymentResponse] model class for managing payment responses.
class UniPaymentResponse {
  String message;
  bool paymentStatus;
  String paymentId;

  UniPaymentResponse(
    this.message,
    this.paymentStatus,
    this.paymentId,
  );
}
