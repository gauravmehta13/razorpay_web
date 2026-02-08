import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:razorpay_web/razorpay_web.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Razorpay _razorpay;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: _scaffoldMessengerKey,
      home: Builder(
        builder: (context) => Scaffold(
          appBar: appBar(),
          body: body(context),
        ),
      ),
    );
  }

  AppBar appBar() {
    return AppBar(
      title: const Text('Razorpay Sample App'),
    );
  }

  Widget body(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            listtile(context, true),
            listtile(context, false),
            payButton(context),
          ],
        ));
  }

  Widget listtile(BuildContext context, bool isSucess) {
    ///Reference: https://razorpay.com/docs/payments/payments/test-upi-details/
    String text = isSucess ? 'success@razorpay' : 'failure@razorpay';
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        tileColor: isSucess ? Colors.green.shade50 : Colors.red.shade50,
        title: Text(text),
        subtitle: Text(
          'UPI ID For ${isSucess ? 'successful' : 'failed'} payment',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: IconButton(
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: text));
            _showSnackBar("Copied to clipboard");
            await Future.delayed((const Duration(seconds: 1))).then((_) {
              // ignore: use_build_context_synchronously
              openCheckout(context);
            });
          },
          tooltip: 'Copy',
          icon: const Icon(Icons.copy),
        ),
      ),
    );
  }

  Widget payButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () => openCheckout(context),
      child: const Text('Pay'),
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

  void openCheckout(BuildContext context) {
    var options = {
      'key': 'rzp_test_1DP5mmOlF5G5ag',
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
      // Pass context for Windows platform support
      _razorpay.open(options, context: context);
    } catch (e) {
      debugPrint('Error: e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    log('Success Response: $response');
    _showSnackBar(
      "SUCCESS: ${response.paymentId!}",
      backgroundColor: Colors.green,
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    log('Error Response: ${response.message}');
    _showSnackBar(
      "ERROR: ${response.code} - ${response.message!}",
      backgroundColor: Colors.red,
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    log('External SDK Response: $response');
    _showSnackBar("EXTERNAL_WALLET: ${response.walletName!}");
  }

  void _showSnackBar(String message, {Color? backgroundColor}) {
    _scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
