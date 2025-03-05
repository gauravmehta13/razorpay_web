import 'package:razorpay_web/Constants/Constants.dart';

/// Payment response classes
class PaymentFailureResponse {
  int? code;
  String? message;

  PaymentFailureResponse(this.code, this.message);

  static PaymentFailureResponse fromMap(Map<dynamic, dynamic> map) {
    var code = map["code"] as int?;
    var message = map["message"] as String?;
    return PaymentFailureResponse(code, message);
  }

  Jsonn get toJson => {
        'code': code,
        'message': message,
      };
}
