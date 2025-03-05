import 'dart:async';
import 'dart:js' as js;

class PayFn {
  static const _CODE_PAYMENT_SUCCESS = 0;
  static const _CODE_PAYMENT_ERROR = 1;
  static const PAYMENT_CANCELLED = 2;
  static const BASE_REQUEST_ERROR = 5;

  /// Starts the payment flow
  Future<Map<dynamic, dynamic>> startPayment(Map<dynamic, dynamic> options) async {
    // Completer to return future response
    var completer = Completer<Map<dynamic, dynamic>>();

    var returnMap = <dynamic, dynamic>{}; // Main return object
    var dataMap = <dynamic, dynamic>{}; // Data object

    // Ensure Razorpay SDK is loaded before proceeding
    if (!js.context.hasProperty('Razorpay')) {
      completer.completeError("Razorpay SDK not loaded");
      return completer.future;
    }

    void handlerFn(response) {
      returnMap['type'] = _CODE_PAYMENT_SUCCESS;
      dataMap['razorpay_payment_id'] = response['razorpay_payment_id'];
      dataMap['razorpay_order_id'] = response['razorpay_order_id'];
      dataMap['razorpay_signature'] = response['razorpay_signature'];
      returnMap['data'] = dataMap;
      completer.complete(returnMap);
    }

    void dismissFn() {
      if (!completer.isCompleted) {
        returnMap['type'] = _CODE_PAYMENT_ERROR;
        dataMap['code'] = PAYMENT_CANCELLED;
        dataMap['message'] = 'Payment processing cancelled by user';
        returnMap['data'] = dataMap;
        completer.complete(returnMap);
      }
    }

    // Handle payment failure
    void onFailedFn(response) {
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
    }

    options['handler'] = handlerFn;
    options['modal.ondismiss'] = dismissFn;

    // Initialize Razorpay instance
    js.JsObject jsmapFromDart = js.JsObject.jsify(options);
    Object browserObject = js.context.callMethod('Razorpay', [jsmapFromDart]);
    js.JsObject razorpay = js.JsObject.fromBrowserObject(browserObject);

    razorpay.callMethod('on', ['payment.failed', onFailedFn]);
    razorpay.callMethod('open');
    return completer.future;
  }
}
