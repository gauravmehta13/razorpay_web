library razorpay_web;

import 'package:eventify/eventify.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:universal_platform/universal_platform.dart';

import 'Constants/Constants.dart';

export 'Constants/Constants.dart';

/// Flutter plugin for Razorpay SDK
class Razorpay {
  static const MethodChannel _channel = MethodChannel('razorpay_flutter');

  // EventEmitter instance used for communication
  late EventEmitter _eventEmitter;

  Razorpay() {
    _eventEmitter = EventEmitter();
  }

  /// Opens Razorpay checkout
  void open(Map<String, dynamic> options) async {
    Map<String, dynamic> validationResult = _validateOptions(options);

    if (!validationResult['success']) {
      _handleResult({
        'type': ResponseCodes.CODE_PAYMENT_ERROR,
        'data': {
          'code': ResponseCodes.INVALID_OPTIONS,
          'message': validationResult['message'],
        }
      });
      return;
    }

    if (UniversalPlatform.isAndroid) {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      _channel.invokeMethod('setPackageName', packageInfo.packageName);
    }

    var response = await _channel.invokeMethod('open', options);
    _handleResult(response);
  }

  /// Handles checkout response from platform
  void _handleResult(Map<dynamic, dynamic> response) {
    String eventName;
    Map<dynamic, dynamic>? data = response["data"];

    dynamic payload;

    switch (response['type']) {
      case ResponseCodes.CODE_PAYMENT_SUCCESS:
        eventName = RazorpayEvents.EVENT_PAYMENT_SUCCESS;
        payload = PaymentSuccessResponse.fromMap(data!);
        break;

      case ResponseCodes.CODE_PAYMENT_ERROR:
        eventName = RazorpayEvents.EVENT_PAYMENT_ERROR;
        payload = PaymentFailureResponse.fromMap(data!);
        break;

      case ResponseCodes.CODE_PAYMENT_EXTERNAL_WALLET:
        eventName = RazorpayEvents.EVENT_EXTERNAL_WALLET;
        payload = ExternalWalletResponse.fromMap(data!);
        break;

      default:
        eventName = 'error';
        payload = PaymentFailureResponse(ResponseCodes.UNKNOWN_ERROR, 'An unknown error occurred.');
    }

    _eventEmitter.emit(eventName, null, payload);
  }

  /// Registers event listeners for payment events
  void on(String event, Function handler) {
    cb(event, cont) {
      handler(event.eventData);
    }

    _eventEmitter.on(event, null, cb);
    _resync();
  }

  /// Clears all event listeners
  void clear() {
    _eventEmitter.clear();
  }

  /// Retrieves lost responses from platform
  void _resync() async {
    var response = await _channel.invokeMethod('resync');
    if (response != null) {
      _handleResult(response);
    }
  }

  /// Validate payment options
  static Map<String, dynamic> _validateOptions(Map<String, dynamic> options) {
    var key = options['key'];
    if (key == null) {
      return {'success': false, 'message': 'Key is required. Please check if key is present in options.'};
    }
    return {'success': true};
  }
}

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
}

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
}

class ExternalWalletResponse {
  String? walletName;

  ExternalWalletResponse(this.walletName);

  static ExternalWalletResponse fromMap(Map<dynamic, dynamic> map) {
    var walletName = map["external_wallet"] as String?;
    return ExternalWalletResponse(walletName);
  }
}
