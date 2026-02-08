import 'package:flutter_test/flutter_test.dart';
import 'package:razorpay_web/razorpay_flutter_webview.dart';

/// Tests for RazorpayFlutterWebView
/// Note: WebView widget tests require InAppWebView platform implementation
/// which is not available in unit test environment. These tests only verify
/// basic instantiation and registration.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RazorpayFlutterWebView Tests', () {
    test('registerWith does not throw', () {
      expect(() => RazorpayFlutterWebView.registerWith(), returnsNormally);
    });

    test('instance can be created', () {
      final webViewPlugin = RazorpayFlutterWebView();
      expect(webViewPlugin, isNotNull);
      expect(webViewPlugin, isA<RazorpayFlutterWebView>());
    });
  });
}
