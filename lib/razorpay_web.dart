import 'package:eventify/eventify.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:universal_platform/universal_platform.dart';

import 'razorpay_events.dart';
import 'razorpay_flutter_windows.dart';
export 'razorpay_events.dart';

/// Flutter plugin for Razorpay SDK
class Razorpay {
  // Response codes from platform
  static const _CODE_PAYMENT_SUCCESS = ResponseCodes.CODE_PAYMENT_SUCCESS;
  static const _CODE_PAYMENT_ERROR = ResponseCodes.CODE_PAYMENT_ERROR;
  static const _CODE_PAYMENT_EXTERNAL_WALLET =
      ResponseCodes.CODE_PAYMENT_EXTERNAL_WALLET;

  // Event names
  static const EVENT_PAYMENT_SUCCESS = RazorpayEvents.EVENT_PAYMENT_SUCCESS;
  static const EVENT_PAYMENT_ERROR = RazorpayEvents.EVENT_PAYMENT_ERROR;
  static const EVENT_EXTERNAL_WALLET = RazorpayEvents.EVENT_EXTERNAL_WALLET;

  // Payment error codes
  static const NETWORK_ERROR = ResponseCodes.NETWORK_ERROR;
  static const INVALID_OPTIONS = ResponseCodes.INVALID_OPTIONS;
  static const PAYMENT_CANCELLED = ResponseCodes.PAYMENT_CANCELLED;
  static const TLS_ERROR = ResponseCodes.TLS_ERROR;
  static const INCOMPATIBLE_PLUGIN = ResponseCodes.INCOMPATIBLE_PLUGIN;
  static const UNKNOWN_ERROR = ResponseCodes.UNKNOWN_ERROR;

  static const MethodChannel _channel = MethodChannel('razorpay_flutter');

  // EventEmitter instance used for communication
  late EventEmitter _eventEmitter;

  Razorpay() {
    _eventEmitter = EventEmitter();
  }

  /// Opens Razorpay checkout
  ///
  /// [options] - Payment options including key, amount, description, etc.
  /// [context] - BuildContext required for Windows platform to show the payment dialog.
  ///             Optional for Android, iOS, and Web platforms.
  void open(Map<String, dynamic> options, {BuildContext? context}) async {
    Map<String, dynamic> validationResult = _validateOptions(options);

    if (!validationResult['success']) {
      _handleResult({
        'type': _CODE_PAYMENT_ERROR,
        'data': {
          'code': INVALID_OPTIONS,
          'message': validationResult['message']
        }
      });
      return;
    }

    // Handle Windows platform via InAppWebView
    if (UniversalPlatform.isWindows) {
      if (context == null) {
        _handleResult({
          'type': _CODE_PAYMENT_ERROR,
          'data': {
            'code': INVALID_OPTIONS,
            'message':
                'BuildContext is required for Windows platform. Please pass context parameter to open() method.'
          }
        });
        return;
      }
      final windowsPlugin = RazorpayFlutterWindows();
      var response = await windowsPlugin.open(context, options);
      _handleResult(response);
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
      case _CODE_PAYMENT_SUCCESS:
        eventName = EVENT_PAYMENT_SUCCESS;
        payload = PaymentSuccessResponse.fromMap(data!);
        break;

      case _CODE_PAYMENT_ERROR:
        eventName = EVENT_PAYMENT_ERROR;
        payload = PaymentFailureResponse.fromMap(data!);
        break;

      case _CODE_PAYMENT_EXTERNAL_WALLET:
        eventName = EVENT_EXTERNAL_WALLET;
        payload = ExternalWalletResponse.fromMap(data!);
        break;

      default:
        eventName = 'error';
        payload =
            PaymentFailureResponse(UNKNOWN_ERROR, 'An unknown error occurred.');
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
    // Skip resync for Windows and Web as they don't use method channels
    if (UniversalPlatform.isWindows || UniversalPlatform.isWeb) {
      return;
    }

    var response = await _channel.invokeMethod('resync');
    if (response != null) {
      _handleResult(response);
    }
  }

  /// Validate payment options
  static Map<String, dynamic> _validateOptions(Map<String, dynamic> options) {
    var key = options['key'];
    if (key == null) {
      return {
        'success': false,
        'message': 'Key is required. Please check if key is present in options.'
      };
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
