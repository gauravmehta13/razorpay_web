import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_web/razorpay_web.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Razorpay _razorpay;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Razorpay Sample App'),
        ),
        body: Center(
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
              ElevatedButton(onPressed: openCheckout, child: const Text('Open'))
            ])),
      ),
    );
  }

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
    super.dispose();
    _razorpay.clear();
  }

  void openCheckout() async {
    var options = {
      'key': kDebugMode ? 'rzp_test_1DP5mmOlF5G5ag' : "rzp_live_h33xU21Pn6h51e",
      'amount': 100,
      'name': 'Acme Corp.',
      'description': 'Fine T-Shirt',
      'send_sms_hash': true,
      'prefill': {'contact': '8888888888', 'email': 'test@razorpay.com'},
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    print('Payment Id: ${response.paymentId}');
    print('Order Id: ${response.orderId}');
    print('Signature: ${response.signature}');
    // show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('SUCCESS: Payment Id: ${response.paymentId}'),
      ),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print('Code: ${response.code}');
    print('Message: ${response.message}');

    // show error message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('ERROR: ${response.message}'),
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print('EXTERNAL_WALLET: ${response.walletName}');
    // show external wallet name
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('EXTERNAL_WALLET: ${response.walletName}'),
      ),
    );
  }
}
