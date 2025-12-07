import 'dart:collection';
import 'dart:js_interop' as jsinterop;
import 'dart:js_interop_unsafe' as jsinterop_unsafe;

import 'package:flutter/foundation.dart';
import 'package:razorpay_web/razorpay_web.dart';
import 'package:web/web.dart' as web;

///A service class which only manages the payment process for better code readability
class PayService {
  /// Starts the payment flow
  Future<RpayMap> startPayment(RpayMap options) async {
    // Completer to return future response
    RpayCompleter completer = RpayCompleter();

    /// Main return object
    RpayMap returnMap = <dynamic, dynamic>{};

    /// Data object
    RpayMap dataMap = <dynamic, dynamic>{};

    ///Ensure Razorpay SDK is loaded before proceeding
    bool isRazorpayLoaded = web.window.has('Razorpay');

    /// Optionally we can use this double conversion method also:
    /// bool isRazorpayLoaded = web.window.hasProperty('Razorpay'.toJS).toDart;

    if (isRazorpayLoaded == false) {
      completer.completeError("Razorpay SDK not loaded");
      return completer.future;
    }

    ///The dart function which will be called when payment is successful
    void handlerFn(jsinterop.JSObject jsResponse) {
      debugPrint('handlerFn called');

      ///Retriving Dart object from JS object
      Object? responseDartObject = jsResponse.dartify();

      ///If not null then parse it back as dart map
      if (responseDartObject != null) {
        Map response = Map.from(responseDartObject as LinkedHashMap);
        returnMap['type'] = ResponseCodes.CODE_PAYMENT_SUCCESS;
        dataMap['razorpay_payment_id'] = response['razorpay_payment_id'];
        dataMap['razorpay_order_id'] = response['razorpay_order_id'];
        dataMap['razorpay_signature'] = response['razorpay_signature'];
        returnMap['data'] = dataMap;
        completer.complete(returnMap);
      } else {
        debugPrint('response is not Map');
      }
    }

    ///The dart function which will be called when dialogue is closed by clicking close button
    void dismissFn() {
      debugPrint('dismissFn called');
      if (!completer.isCompleted) {
        returnMap['type'] = ResponseCodes.CODE_PAYMENT_ERROR;
        dataMap['code'] = ResponseCodes.PAYMENT_CANCELLED;
        dataMap['message'] = 'Payment processing cancelled by user';
        returnMap['data'] = dataMap;
        completer.complete(returnMap);
      }
    }

    /// Dart function to handle payment failure
    void onFailedFn(jsinterop.JSObject jsResponse) {
      debugPrint('onFailedFn called');
      Object? dartObject = jsResponse.dartify();
      if (dartObject != null) {
        Map response = Map.from(dartObject as LinkedHashMap);
        returnMap['type'] = ResponseCodes.CODE_PAYMENT_ERROR;
        dataMap['code'] = ResponseCodes.BASE_REQUEST_ERROR;
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

    /// Converting dart map to js object
    /// [NOTE] handler functions should not be added before jsify,
    /// if we pass them like options['handler'] = handlerFn, then it will be
    /// a dart function and not a js function so in release mode the success, or failiure, or dismiss
    /// handlers will not be executed.
    /// Also if we call .toJS before jsify(), it's not running so we have to
    /// put all the handlers to the newly created [jsmapFromDart]
    jsinterop.JSAny? jsmapFromDart = options.jsify();

    /// Now manually insert the function handlers as JS object
    if (jsmapFromDart != null && jsmapFromDart.isA<jsinterop.JSObject>()) {
      // Now manually insert the function handlers into the JS object
      final jsMap = jsmapFromDart as jsinterop.JSObject;
      jsMap.setProperty('handler'.toJS, handlerFn.toJS);
      jsMap.setProperty('modal.ondismiss'.toJS, dismissFn.toJS);
      jsMap.setProperty('payment.failed'.toJS, onFailedFn.toJS);
    }

    /// Retrieving the Object named [Razorpay] from the .js file we received from checkout API
    jsinterop.JSAny? razorpay =
        web.window.callMethod('Razorpay'.toJS, jsmapFromDart);

    if (razorpay != null && razorpay.isA<jsinterop.JSObject>()) {
      final razorpayObj = razorpay as jsinterop.JSObject;

      ///Assigning the onFailedFn to the payment.failed event
      razorpayObj.callMethod('on'.toJS, 'payment.failed'.toJS, onFailedFn.toJS);

      ///If no errors captured, then execute the ['open'] method
      razorpayObj.callMethod('open'.toJS);
    }
    return completer.future;
  }
}
