import 'dart:async';
import 'dart:collection';
// import 'dart:js' as js;
import 'dart:js_interop' as jsinterop;
import 'dart:js_interop_unsafe' as jsinterop_unsafe;

import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

class PayFn {
  static const _CODE_PAYMENT_SUCCESS = 0;
  static const _CODE_PAYMENT_ERROR = 1;
  static const PAYMENT_CANCELLED = 2;
  static const BASE_REQUEST_ERROR = 5;

  /// Starts the payment flow
  Future<Map<dynamic, dynamic>> startPayment(Map<dynamic, dynamic> options) async {
    // Completer to return future response
    var completer = Completer<Map<dynamic, dynamic>>();

    /// Main return object
    var returnMap = <dynamic, dynamic>{};

    /// Data object
    var dataMap = <dynamic, dynamic>{};

    // Ensure Razorpay SDK is loaded before proceeding
    // bool isRazorpayLoaded = js.context.hasProperty('Razorpay');
    // bool isRazorpayLoadedMethod1 = web.window.hasProperty('Razorpay'.toJS).toDart;
    bool isRazorpayLoaded = web.window.has('Razorpay');

    if (isRazorpayLoaded == false) {
      completer.completeError("Razorpay SDK not loaded");
      return completer.future;
    }

    void handlerFn(jsinterop.JSObject jsResponse) {
      Object? responseDartObject = jsResponse.dartify();
      debugPrint('response type: ${responseDartObject.runtimeType}');
      if (responseDartObject != null) {
        Map response = Map.from(responseDartObject as LinkedHashMap);
        returnMap['type'] = _CODE_PAYMENT_SUCCESS;
        dataMap['razorpay_payment_id'] = response['razorpay_payment_id'];
        dataMap['razorpay_order_id'] = response['razorpay_order_id'];
        dataMap['razorpay_signature'] = response['razorpay_signature'];
        returnMap['data'] = dataMap;
        completer.complete(returnMap);
      } else {
        debugPrint('response is not Map');
      }
    }

    void dismissFn() {
      debugPrint('dismissed');
      if (!completer.isCompleted) {
        returnMap['type'] = _CODE_PAYMENT_ERROR;
        dataMap['code'] = PAYMENT_CANCELLED;
        dataMap['message'] = 'Payment processing cancelled by user';
        returnMap['data'] = dataMap;
        completer.complete(returnMap);
      }
    }

    // Handle payment failure
    void onFailedFn(jsinterop.JSObject jsResponse) {
      debugPrint('error onFailedFn');
      Object? dartObject = jsResponse.dartify();
      if (dartObject != null) {
        Map response = Map.from(dartObject as LinkedHashMap);
        returnMap['type'] = _CODE_PAYMENT_ERROR;
        dataMap['code'] = BASE_REQUEST_ERROR;
        dataMap['message'] = response['error']['description'];
        var metadataMap = <dynamic, dynamic>{};
        metadataMap['payment_id'] = response['error']['metadata']['payment_id'];
        dataMap['metadata'] = metadataMap;
        dataMap['source'] = response['error']['source'];
        dataMap['step'] = response['error']['step'];
        returnMap['data'] = dataMap;
        completer.complete(returnMap);
      } else {
        debugPrint('onFailedFn response is not Map');
      }
    }

    options['handler'] = handlerFn;
    options['modal.ondismiss'] = dismissFn;

    // Initialize Razorpay instance
    /// Converting dart map to js object
    // js.JsObject jsmapFromDart = js.JsObject.jsify(options);
    jsinterop.JSAny? jsmapFromDart = options.jsify();

    /// Retrieving Browser Object named Razorpay from the .js file we received from checkout API
    jsinterop.JSAny? razorpay = web.window.callMethod('Razorpay'.toJS, jsmapFromDart);

    /// Converting Browser Object to JS Object
    // js.JsObject razorpay = js.JsObject.fromBrowserObject(browserObject);

    if (razorpay is jsinterop.JSObject) {
      ///Assigning the onFailedFn to the payment.failed event
      razorpay.callMethod('on'.toJS, onFailedFn.toJS);

      ///If no errors captured, then execute the ['open'] method
      razorpay.callMethod('open'.toJS);
    }
    return completer.future;
  }
}
