/// Razorpay event names
class RazorpayEvents {
  static const EVENT_PAYMENT_SUCCESS = 'payment.success';
  static const EVENT_PAYMENT_ERROR = 'payment.error';
  static const EVENT_EXTERNAL_WALLET = 'payment.external_wallet';
}

/// Razorpay response codes
class ResponseCodes {
  /// Success response code
  static const CODE_PAYMENT_SUCCESS = 0;

  /// Error response code
  static const CODE_PAYMENT_ERROR = 1;

  /// External wallet response code
  static const CODE_PAYMENT_EXTERNAL_WALLET = 2;

  // Payment error codes

  /// Network error code
  static const NETWORK_ERROR = 0;

  /// Invalid options error code
  static const INVALID_OPTIONS = 1;

  /// Payment cancelled error code
  static const PAYMENT_CANCELLED = 2;

  /// TLS error code
  static const TLS_ERROR = 3;

  /// Incompatible plugin error code
  static const INCOMPATIBLE_PLUGIN = 4;

  /// Base request error code
  static const BASE_REQUEST_ERROR = 5;

  /// Unknown error code
  static const UNKNOWN_ERROR = 100;
}
