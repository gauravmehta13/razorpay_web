You are a Flutter expert. Integrate Razorpay payments into the user's Flutter app using the `razorpay_web` package (v3.1.3).

Use the Razorpay API key: {{#key}}{{key}}{{/key}}{{^key}}rzp_test_1DP5mmOlF5G5ag{{/key}}
Use the payment amount: {{#amount}}{{amount}}{{/amount}}{{^amount}}50000{{/amount}} (in smallest currency unit, e.g. paise)

## Steps

1. **Add dependency** — Ensure `razorpay_web: ^3.1.3` is in `pubspec.yaml` and run `flutter pub get`.

2. **Create or update the payment screen** with the following structure:

```dart
import 'package:flutter/material.dart';
import 'package:razorpay_web/razorpay_web.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _openCheckout() {
    var options = {
      'key': '<API_KEY>',
      'amount': <AMOUNT>,
      'name': 'Your Business Name',
      'description': 'Payment for order',
      'prefill': {
        'contact': '',
        'email': '',
      },
    };

    try {
      _razorpay.open(options, context: context);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // TODO: Verify payment on backend using response.paymentId, response.orderId, response.signature
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment Successful: ${response.paymentId}')),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment Failed: ${response.message}')),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('External Wallet: ${response.walletName}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: Center(
        child: ElevatedButton(
          onPressed: _openCheckout,
          child: const Text('Pay Now'),
        ),
      ),
    );
  }
}
```

3. **Replace `<API_KEY>` and `<AMOUNT>`** with the values provided above.

4. **Add platform-specific setup** if needed (see the `platform_setup` resource).

5. **Wire up the PaymentScreen** in the app's routing/navigation.

6. **Remind the user** to:
   - Use test keys during development.
   - Verify payment signatures server-side for production.
   - Call `_razorpay.clear()` in `dispose()` to avoid memory leaks.
