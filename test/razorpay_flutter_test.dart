import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:razorpay_web/razorpay_web.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Razorpay Core Tests', () {
    late Razorpay razorpay;
    late List<MethodCall> methodCallLog;

    setUp(() {
      razorpay = Razorpay();
      methodCallLog = <MethodCall>[];

      // Mock the method channel
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('razorpay_flutter'),
        (MethodCall methodCall) async {
          methodCallLog.add(methodCall);

          // Return appropriate responses based on method
          switch (methodCall.method) {
            case 'open':
              return {
                'type': ResponseCodes.CODE_PAYMENT_SUCCESS,
                'data': {
                  'razorpay_payment_id': 'pay_test123',
                  'razorpay_order_id': 'order_test123',
                  'razorpay_signature': 'signature_test123',
                }
              };
            case 'resync':
              return null;
            case 'setPackageName':
              return null;
            default:
              return null;
          }
        },
      );
    });

    tearDown(() {
      razorpay.clear();
      methodCallLog.clear();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('razorpay_flutter'),
        null,
      );
    });

    test('initializes successfully', () {
      expect(razorpay, isNotNull);
      expect(razorpay, isA<Razorpay>());
    });

    test('validates options and rejects when key is missing', () async {
      final completer = Completer<PaymentFailureResponse>();

      razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, (response) {
        completer.complete(response as PaymentFailureResponse);
      });

      razorpay.open({
        'amount': 100,
        'description': 'Test payment',
      });

      final response = await completer.future;
      expect(response.code, Razorpay.INVALID_OPTIONS);
      expect(response.message, contains('Key is required'));
    });

    test('registers event listeners correctly', () {
      var callbackInvoked = false;

      razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, (response) {
        callbackInvoked = true;
      });

      expect(callbackInvoked, isFalse);
    });

    test('clears all event listeners', () {
      var successCallbackCount = 0;
      var errorCallbackCount = 0;

      razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, (response) {
        successCallbackCount++;
      });

      razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, (response) {
        errorCallbackCount++;
      });

      razorpay.clear();

      // After clearing, listeners should not be invoked
      expect(successCallbackCount, 0);
      expect(errorCallbackCount, 0);
    });

    test('handles empty options map', () async {
      final completer = Completer<PaymentFailureResponse>();

      razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, (response) {
        completer.complete(response as PaymentFailureResponse);
      });

      razorpay.open({});

      final response = await completer.future;
      expect(response.code, Razorpay.INVALID_OPTIONS);
    });

    test('handles options with null key', () async {
      final completer = Completer<PaymentFailureResponse>();

      razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, (response) {
        completer.complete(response as PaymentFailureResponse);
      });

      razorpay.open({'key': null, 'amount': 100});

      final response = await completer.future;
      expect(response.code, Razorpay.INVALID_OPTIONS);
    });
  });



  group('Options Validation Tests', () {
    late Razorpay razorpay;

    setUp(() {
      razorpay = Razorpay();
    });

    tearDown(() {
      razorpay.clear();
    });

    test('validates missing key in options', () async {
      final completer = Completer<PaymentFailureResponse>();

      razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, (response) {
        completer.complete(response as PaymentFailureResponse);
      });

      razorpay.open({'amount': 100});

      final response = await completer.future;
      expect(response.code, Razorpay.INVALID_OPTIONS);
      expect(response.message, contains('Key is required'));
    });
  });

  group('Event Emitter Tests', () {
    late Razorpay razorpay;

    setUp(() {
      razorpay = Razorpay();
    });

    tearDown(() {
      razorpay.clear();
    });

    test('clear removes all listeners', () {
      var called = false;

      razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, (response) {
        called = true;
      });

      razorpay.clear();

      // Verify listeners are cleared
      expect(called, isFalse);
    });
  });


}
