import 'package:razorpay_web/razorpay_web.dart';

/// Payment response classes
class PaymentSuccessResponse {
  /// Payment id
  String? paymentId;

  /// Order id
  String? orderId;

  /// Signature
  String? signature;

  PaymentSuccessResponse(this.paymentId, this.orderId, this.signature);

  static PaymentSuccessResponse fromMap(Map<dynamic, dynamic> map) {
    String? paymentId = map["razorpay_payment_id"];
    String? signature = map["razorpay_signature"];
    String? orderId = map["razorpay_order_id"];

    return PaymentSuccessResponse(paymentId, orderId, signature);
  }

  Jsonn get toJson => {
        'razorpay_payment_id': paymentId,
        'razorpay_order_id': orderId,
        'razorpay_signature': signature,
      };
}
