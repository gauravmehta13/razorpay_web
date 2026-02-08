import 'package:flutter_test/flutter_test.dart';
import 'package:razorpay_web/razorpay_web.dart';

/// Tests for Razorpay response models and constants
/// These tests don't require platform channels or async operations
void main() {
  group('PaymentSuccessResponse Tests', () {
    test('creates from map with all fields', () {
      final map = {
        'razorpay_payment_id': 'pay_123',
        'razorpay_order_id': 'order_123',
        'razorpay_signature': 'sig_123',
      };

      final response = PaymentSuccessResponse.fromMap(map);

      expect(response.paymentId, 'pay_123');
      expect(response.orderId, 'order_123');
      expect(response.signature, 'sig_123');
    });

    test('creates from map with missing optional fields', () {
      final map = {
        'razorpay_payment_id': 'pay_123',
      };

      final response = PaymentSuccessResponse.fromMap(map);

      expect(response.paymentId, 'pay_123');
      expect(response.orderId, isNull);
      expect(response.signature, isNull);
    });

    test('creates from empty map', () {
      final response = PaymentSuccessResponse.fromMap({});

      expect(response.paymentId, isNull);
      expect(response.orderId, isNull);
      expect(response.signature, isNull);
    });

    test('handles special characters in payment data', () {
      final map = {
        'razorpay_payment_id': 'pay_<script>alert("xss")</script>',
        'razorpay_order_id': 'order_"quotes"',
        'razorpay_signature': 'sig_\n\t\r',
      };

      final response = PaymentSuccessResponse.fromMap(map);

      expect(response.paymentId, contains('<script>'));
      expect(response.orderId, contains('"quotes"'));
      expect(response.signature, contains('\n'));
    });

    test('handles unicode characters', () {
      final map = {
        'razorpay_payment_id': 'pay_测试_🚀',
        'razorpay_order_id': 'order_テスト',
        'razorpay_signature': 'sig_مرحبا',
      };

      final response = PaymentSuccessResponse.fromMap(map);

      expect(response.paymentId, 'pay_测试_🚀');
      expect(response.orderId, 'order_テスト');
      expect(response.signature, 'sig_مرحبا');
    });

    test('handles very long strings', () {
      final longString = 'a' * 10000;
      final map = {
        'razorpay_payment_id': longString,
      };

      final response = PaymentSuccessResponse.fromMap(map);

      expect(response.paymentId, longString);
      expect(response.paymentId?.length, 10000);
    });
  });

  group('PaymentFailureResponse Tests', () {
    test('creates from map with integer code', () {
      final map = {
        'code': 0,
        'message': 'Network error',
      };

      final response = PaymentFailureResponse.fromMap(map);

      expect(response.code, 0);
      expect(response.message, 'Network error');
    });

    test('creates from map with string code', () {
      final map = {
        'code': 'BAD_REQUEST_ERROR',
        'message': 'Invalid request',
      };

      final response = PaymentFailureResponse.fromMap(map);

      expect(response.code, 'BAD_REQUEST_ERROR');
      expect(response.message, 'Invalid request');
    });

    test('creates from map with null message', () {
      final map = {
        'code': 1,
        'message': null,
      };

      final response = PaymentFailureResponse.fromMap(map);

      expect(response.code, 1);
      expect(response.message, isNull);
    });

    test('creates from empty map', () {
      final response = PaymentFailureResponse.fromMap({});

      expect(response.code, isNull);
      expect(response.message, isNull);
    });

    test('handles dynamic code types', () {
      // Test with integer
      final intResponse = PaymentFailureResponse.fromMap({
        'code': 42,
        'message': 'Error',
      });
      expect(intResponse.code, 42);
      expect(intResponse.code, isA<int>());

      // Test with string
      final stringResponse = PaymentFailureResponse.fromMap({
        'code': 'CUSTOM_ERROR',
        'message': 'Error',
      });
      expect(stringResponse.code, 'CUSTOM_ERROR');
      expect(stringResponse.code, isA<String>());
    });

    test('handles all standard error codes', () {
      final errorCodes = [
        ResponseCodes.NETWORK_ERROR,
        ResponseCodes.INVALID_OPTIONS,
        ResponseCodes.PAYMENT_CANCELLED,
        ResponseCodes.TLS_ERROR,
        ResponseCodes.INCOMPATIBLE_PLUGIN,
        ResponseCodes.BASE_REQUEST_ERROR,
        ResponseCodes.UNKNOWN_ERROR,
      ];

      for (final code in errorCodes) {
        final response = PaymentFailureResponse.fromMap({
          'code': code,
          'message': 'Test error',
        });
        expect(response.code, code);
      }
    });

    test('handles multiline error messages', () {
      final map = {
        'code': 1,
        'message': 'Line 1\nLine 2\nLine 3',
      };

      final response = PaymentFailureResponse.fromMap(map);

      expect(response.message, contains('\n'));
      expect(response.message?.split('\n').length, 3);
    });
  });

  group('ExternalWalletResponse Tests', () {
    test('creates from map with wallet name', () {
      final map = {
        'external_wallet': 'paytm',
      };

      final response = ExternalWalletResponse.fromMap(map);

      expect(response.walletName, 'paytm');
    });

    test('creates from map with null wallet name', () {
      final map = {
        'external_wallet': null,
      };

      final response = ExternalWalletResponse.fromMap(map);

      expect(response.walletName, isNull);
    });

    test('creates from empty map', () {
      final response = ExternalWalletResponse.fromMap({});

      expect(response.walletName, isNull);
    });

    test('handles various wallet names', () {
      final wallets = [
        'paytm',
        'phonepe',
        'googlepay',
        'amazonpay',
        'mobikwik',
        'freecharge',
        'jiomoney',
        'airtel',
      ];

      for (final wallet in wallets) {
        final response = ExternalWalletResponse.fromMap({
          'external_wallet': wallet,
        });
        expect(response.walletName, wallet);
      }
    });

    test('handles wallet names with special characters', () {
      final map = {
        'external_wallet': 'wallet-name_123',
      };

      final response = ExternalWalletResponse.fromMap(map);

      expect(response.walletName, 'wallet-name_123');
    });
  });

  group('Event Constants Tests', () {
    test('event names are correctly defined', () {
      expect(Razorpay.EVENT_PAYMENT_SUCCESS, 'payment.success');
      expect(Razorpay.EVENT_PAYMENT_ERROR, 'payment.error');
      expect(Razorpay.EVENT_EXTERNAL_WALLET, 'payment.external_wallet');
    });

    test('event names match RazorpayEvents constants', () {
      expect(Razorpay.EVENT_PAYMENT_SUCCESS,
          RazorpayEvents.EVENT_PAYMENT_SUCCESS);
      expect(
          Razorpay.EVENT_PAYMENT_ERROR, RazorpayEvents.EVENT_PAYMENT_ERROR);
      expect(Razorpay.EVENT_EXTERNAL_WALLET,
          RazorpayEvents.EVENT_EXTERNAL_WALLET);
    });

    test('error codes are correctly defined', () {
      expect(Razorpay.NETWORK_ERROR, 0);
      expect(Razorpay.INVALID_OPTIONS, 1);
      expect(Razorpay.PAYMENT_CANCELLED, 2);
      expect(Razorpay.TLS_ERROR, 3);
      expect(Razorpay.INCOMPATIBLE_PLUGIN, 4);
      expect(Razorpay.UNKNOWN_ERROR, 100);
    });

    test('response codes are correctly defined', () {
      expect(ResponseCodes.CODE_PAYMENT_SUCCESS, 0);
      expect(ResponseCodes.CODE_PAYMENT_ERROR, 1);
      expect(ResponseCodes.CODE_PAYMENT_EXTERNAL_WALLET, 2);
    });

    test('all error codes are unique', () {
      

      // Check that UNKNOWN_ERROR is distinct
      expect(ResponseCodes.UNKNOWN_ERROR, 100);

      // Check that other codes are in sequence
      expect(ResponseCodes.NETWORK_ERROR, 0);
      expect(ResponseCodes.INVALID_OPTIONS, 1);
      expect(ResponseCodes.PAYMENT_CANCELLED, 2);
      expect(ResponseCodes.TLS_ERROR, 3);
      expect(ResponseCodes.INCOMPATIBLE_PLUGIN, 4);
      expect(ResponseCodes.BASE_REQUEST_ERROR, 5);
    });

    test('response type codes are sequential', () {
      expect(ResponseCodes.CODE_PAYMENT_SUCCESS, 0);
      expect(ResponseCodes.CODE_PAYMENT_ERROR, 1);
      expect(ResponseCodes.CODE_PAYMENT_EXTERNAL_WALLET, 2);
    });
  });

  group('Response Model Constructor Tests', () {
    test('PaymentSuccessResponse constructor works correctly', () {
      final response = PaymentSuccessResponse('pay_123', 'order_123', 'sig_123');

      expect(response.paymentId, 'pay_123');
      expect(response.orderId, 'order_123');
      expect(response.signature, 'sig_123');
    });

    test('PaymentSuccessResponse constructor handles nulls', () {
      final response = PaymentSuccessResponse(null, null, null);

      expect(response.paymentId, isNull);
      expect(response.orderId, isNull);
      expect(response.signature, isNull);
    });

    test('PaymentFailureResponse constructor works correctly', () {
      final response = PaymentFailureResponse(1, 'Error message');

      expect(response.code, 1);
      expect(response.message, 'Error message');
    });

    test('PaymentFailureResponse constructor handles nulls', () {
      final response = PaymentFailureResponse(null, null);

      expect(response.code, isNull);
      expect(response.message, isNull);
    });

    test('ExternalWalletResponse constructor works correctly', () {
      final response = ExternalWalletResponse('paytm');

      expect(response.walletName, 'paytm');
    });

    test('ExternalWalletResponse constructor handles null', () {
      final response = ExternalWalletResponse(null);

      expect(response.walletName, isNull);
    });
  });

  group('Edge Cases and Boundary Tests', () {
    test('handles empty strings in PaymentSuccessResponse', () {
      final map = {
        'razorpay_payment_id': '',
        'razorpay_order_id': '',
        'razorpay_signature': '',
      };

      final response = PaymentSuccessResponse.fromMap(map);

      expect(response.paymentId, '');
      expect(response.orderId, '');
      expect(response.signature, '');
    });

    test('handles empty string in PaymentFailureResponse', () {
      final map = {
        'code': '',
        'message': '',
      };

      final response = PaymentFailureResponse.fromMap(map);

      expect(response.code, '');
      expect(response.message, '');
    });

    test('handles whitespace-only strings', () {
      final map = {
        'razorpay_payment_id': '   ',
        'razorpay_order_id': '\t\t',
        'razorpay_signature': '\n\n',
      };

      final response = PaymentSuccessResponse.fromMap(map);

      expect(response.paymentId, '   ');
      expect(response.orderId, '\t\t');
      expect(response.signature, '\n\n');
    });

    test('handles numeric strings in PaymentSuccessResponse', () {
      final map = {
        'razorpay_payment_id': '123456',
        'razorpay_order_id': '789012',
        'razorpay_signature': '345678',
      };

      final response = PaymentSuccessResponse.fromMap(map);

      expect(response.paymentId, '123456');
      expect(response.orderId, '789012');
      expect(response.signature, '345678');
    });

    test('handles zero as error code', () {
      final response = PaymentFailureResponse.fromMap({
        'code': 0,
        'message': 'Zero code',
      });

      expect(response.code, 0);
      expect(response.code, isNot(isNull));
    });

    test('handles negative error codes', () {
      final response = PaymentFailureResponse.fromMap({
        'code': -1,
        'message': 'Negative code',
      });

      expect(response.code, -1);
    });

    test('handles very large error codes', () {
      final response = PaymentFailureResponse.fromMap({
        'code': 999999999,
        'message': 'Large code',
      });

      expect(response.code, 999999999);
    });
  });
}
