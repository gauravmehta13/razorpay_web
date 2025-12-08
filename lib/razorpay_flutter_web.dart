import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:web/web.dart' as web;

import 'razorpay_events.dart';

/// Flutter plugin for Razorpay SDK
class RazorpayFlutterPlugin {
  /// Registers plugin with registrar
  static void registerWith(Registrar registrar) {
    final MethodChannel methodChannel = MethodChannel(
        'razorpay_flutter',
        const StandardMethodCodec(),
        // ignore: deprecated_member_use
        registrar.messenger);
    final RazorpayFlutterPlugin instance = RazorpayFlutterPlugin();
    methodChannel.setMethodCallHandler(instance.handleMethodCall);
  }

  /// Handles method calls over platform channel
  Future<Map<dynamic, dynamic>> handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'open':
        return await startPayment(call.arguments);
      case 'resync':
      default:
        var defaultMap = {'status': 'Not implemented on web'};

        return defaultMap;
    }
  }

  /// Starts the payment flow
  Future<Map<dynamic, dynamic>> startPayment(
      Map<dynamic, dynamic> options) async {
    //required for sending value after the data has been populated
    var completer = Completer<Map<dynamic, dynamic>>();

    var returnMap = <dynamic, dynamic>{}; // main map object
    var dataMap = <dynamic, dynamic>{}; // return map object

    // Handle retry options
    if (options['retry'] is Map && options['retry']['enabled'] == true) {
      options['retry'] = true;
    } else {
      options['retry'] = false;
    }

    // Create script element
    var rzpjs = web.document.createElement('script') as web.HTMLScriptElement;
    rzpjs.id = 'rzp-jssdk';
    rzpjs.src = 'https://checkout.razorpay.com/v1/checkout.js';

    // Define load handler
    void onScriptLoad(web.Event _) {
      // Create JS Options
      var jsOptions = options.jsify() as JSObject;

      // Add handler
      jsOptions.setProperty(
          'handler'.toJS,
          (JSObject response) {
            returnMap['type'] = ResponseCodes.CODE_PAYMENT_SUCCESS;
            dataMap['razorpay_payment_id'] =
                response.getProperty('razorpay_payment_id'.toJS).dartify();

            if (response.hasProperty('razorpay_order_id'.toJS).toDart) {
              dataMap['razorpay_order_id'] =
                  response.getProperty('razorpay_order_id'.toJS).dartify();
            }
            if (response.hasProperty('razorpay_signature'.toJS).toDart) {
              dataMap['razorpay_signature'] =
                  response.getProperty('razorpay_signature'.toJS).dartify();
            }

            returnMap['data'] = dataMap;
            completer.complete(returnMap);
          }.toJS);

      // Add modal.ondismiss
      jsOptions.setProperty(
          'modal.ondismiss'.toJS,
          () {
            if (!completer.isCompleted) {
              returnMap['type'] = ResponseCodes.CODE_PAYMENT_ERROR;
              dataMap['code'] = ResponseCodes.PAYMENT_CANCELLED;
              dataMap['message'] = 'Payment processing cancelled by user';
              returnMap['data'] = dataMap;
              completer.complete(returnMap);
            }
          }.toJS);

      // Initialize Razorpay
      var razorpay = Razorpay(jsOptions);

      // Add failure listener
      razorpay.on(
          'payment.failed',
          (JSObject response) {
            returnMap['type'] = ResponseCodes.CODE_PAYMENT_ERROR;
            dataMap['code'] = ResponseCodes.BASE_REQUEST_ERROR;

            var error = response.getProperty('error'.toJS) as JSObject;
            dataMap['message'] =
                error.getProperty('description'.toJS).dartify();

            var metadataMap = <dynamic, dynamic>{};
            if (error.hasProperty('metadata'.toJS).toDart) {
              var metadata = error.getProperty('metadata'.toJS) as JSObject;
              if (metadata.hasProperty('payment_id'.toJS).toDart) {
                metadataMap['payment_id'] =
                    metadata.getProperty('payment_id'.toJS).dartify();
              }
            }
            dataMap['metadata'] = metadataMap;

            if (error.hasProperty('source'.toJS).toDart) {
              dataMap['source'] = error.getProperty('source'.toJS).dartify();
            }
            if (error.hasProperty('step'.toJS).toDart) {
              dataMap['step'] = error.getProperty('step'.toJS).dartify();
            }

            returnMap['data'] = dataMap;
            completer.complete(returnMap);
          }.toJS);

      razorpay.open();
    }

    rzpjs.addEventListener('load', onScriptLoad.toJS);

    // Insert script logic
    var scripts = web.document.getElementsByTagName('script');
    if (scripts.length > 0) {
      var firstScript = scripts.item(0)!;
      firstScript.parentNode?.insertBefore(rzpjs, firstScript);
    } else {
      web.document.head?.append(rzpjs);
    }

    return completer.future;
  }
}

@JS('Razorpay')
extension type Razorpay._(JSObject _) implements JSObject {
  external Razorpay(JSAny options);
  external void open();
  external void on(String event, JSFunction callback);
}
