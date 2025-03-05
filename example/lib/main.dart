import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
        appBar: appBar(),
        body: body(),
      ),
    );
  }

  AppBar appBar() {
    return AppBar(
      title: const Text('Razorpay Sample App'),
    );
  }

  Widget body() {
    return Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            listtile(true),
            listtile(false),
            ElevatedButton(
              onPressed: openCheckout,
              child: const Text('Pay'),
            ),
          ],
        ));
  }

  Widget listtile(bool isSucess) {
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
            Fluttertoast.showToast(msg: "Copied to clipboard", toastLength: Toast.LENGTH_SHORT);
            await Future.delayed((const Duration(seconds: 1))).then((_) {
              openCheckout();
            });
          },
          tooltip: 'Copy',
          icon: const Icon(Icons.copy),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(RazorpayEvents.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(RazorpayEvents.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(RazorpayEvents.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }

  void openCheckout() async {
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
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    log('Success Response: $response');
    Fluttertoast.showToast(msg: "SUCCESS: ${response.paymentId!}", toastLength: Toast.LENGTH_SHORT);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    log('Error Response: $response');
    Fluttertoast.showToast(
        msg: "ERROR: ${response.code} - ${response.message!}", toastLength: Toast.LENGTH_SHORT, backgroundColor: const Color(0xFFF44336), webBgColor: "linear-gradient(to right, #F44236, #F44336)");
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    log('External SDK Response: $response');
    Fluttertoast.showToast(
      msg: "EXTERNAL_WALLET: ${response.walletName!}",
      toastLength: Toast.LENGTH_SHORT,
    );
  }
}
