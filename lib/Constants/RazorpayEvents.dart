part of './Constants.dart';

/// Primary event names for the payment process
class RazorpayEvents {
  RazorpayEvents._();
  static const EVENT_PAYMENT_SUCCESS = 'payment.success';
  static const EVENT_PAYMENT_ERROR = 'payment.error';
  static const EVENT_EXTERNAL_WALLET = 'payment.external_wallet';
}
