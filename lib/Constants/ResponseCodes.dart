part of './Constants.dart';

///Class to maintain only the know error/response codes
class ResponseCodes {
  ResponseCodes._();

  ///Error codes
  static const CODE_PAYMENT_SUCCESS = 0;
  static const CODE_PAYMENT_ERROR = 1;
  static const BASE_REQUEST_ERROR = 5;

  static const CODE_PAYMENT_EXTERNAL_WALLET = 2;

  // Payment error codes
  static const NETWORK_ERROR = 0;
  static const INVALID_OPTIONS = 1;
  static const PAYMENT_CANCELLED = 2;
  static const TLS_ERROR = 3;
  static const INCOMPATIBLE_PLUGIN = 4;
  static const UNKNOWN_ERROR = 100;
}
