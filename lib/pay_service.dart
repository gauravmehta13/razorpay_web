import 'dart:collection';
import 'dart:developer';
import 'dart:js_interop' as jsinterop;
import 'dart:js_interop_unsafe' as jsinterop_unsafe;
import 'package:web/web.dart' as web;
import 'Constants/Constants.dart';

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

    void handlerFn(jsinterop.JSObject jsResponse) {
      log('handlerFn called');
      Object? responseDartObject = jsResponse.dartify();
      if (responseDartObject != null) {
        Map response = Map.from(responseDartObject as LinkedHashMap);
        returnMap['type'] = ResponseCodes.CODE_PAYMENT_SUCCESS;
        dataMap['razorpay_payment_id'] = response['razorpay_payment_id'];
        dataMap['razorpay_order_id'] = response['razorpay_order_id'];
        dataMap['razorpay_signature'] = response['razorpay_signature'];
        returnMap['data'] = dataMap;
        completer.complete(returnMap);
      } else {
        log('response is not Map');
      }
    }

    void dismissFn() {
      log('dismissFn called');
      if (!completer.isCompleted) {
        returnMap['type'] = ResponseCodes.CODE_PAYMENT_ERROR;
        dataMap['code'] = ResponseCodes.PAYMENT_CANCELLED;
        dataMap['message'] = 'Payment processing cancelled by user';
        returnMap['data'] = dataMap;
        completer.complete(returnMap);
      }
    }

    // Handle payment failure
    void onFailedFn(jsinterop.JSObject jsResponse) {
      log('onFailedFn called');
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
        log('onFailedFn response is not Map');
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
    if (jsmapFromDart != null) {
      // Now manually insert the function handlers into the JS object
      (jsmapFromDart as jsinterop.JSObject).setProperty('handler'.toJS, handlerFn.toJS);
      (jsmapFromDart).setProperty('modal.ondismiss'.toJS, dismissFn.toJS);
      (jsmapFromDart).setProperty('payment.failed'.toJS, onFailedFn.toJS);
    }

    /// Retrieving the Object named [Razorpay] from the .js file we received from checkout API
    jsinterop.JSAny? razorpay = web.window.callMethod('Razorpay'.toJS, jsmapFromDart);

    if (razorpay is jsinterop.JSObject) {
      ///Assigning the onFailedFn to the payment.failed event
      razorpay.callMethod('on'.toJS, 'payment.failed'.toJS, onFailedFn.toJS);

      ///If no errors captured, then execute the ['open'] method
      razorpay.callMethod('open'.toJS);
    }
    return completer.future;
  }
}
