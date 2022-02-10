import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:razorpay_web/src/ui/ui_fake.dart' if (dart.library.html) 'package:razorpay_web/src/ui/ui_real.dart'
    as ui;
import 'package:universal_html/html.dart' as html;

import 'rzp_models.dart';

class RazorpayWeb extends StatefulWidget {
  final String rzpKey;
  final String? rzpSecret;
  final RzpOptions options;
  final Function(String) onPaymentSuccess;
  final Function(String) onPaymentError;
  // final  function(String )  onSuccess;
  RazorpayWeb(
      {required this.rzpKey,
      required this.options,
      required this.onPaymentSuccess,
      required this.onPaymentError,
      this.rzpSecret,
      Key? key})
      : assert(options.generateOrderId == true ? (rzpSecret != null && options.corsUrl != null) : true,
            'Razorpay secret key and Cors Url is required for generating order id'),
        super(key: key);

  @override
  State<RazorpayWeb> createState() => _RazorpayWebState();
}

class _RazorpayWebState extends State<RazorpayWeb> {
  bool canProceed = false;
  @override
  void initState() {
    super.initState();
    if (widget.options.generateOrderId) {
      if (widget.options.corsUrl == null || widget.rzpSecret == null || widget.options.corsUrl!.isEmpty) {
        throw Exception('Razorpay secret key and Cors Url is required for generating order id');
      }
      getOrderId(widget.options).then((value) {
        if (value != null) {
          widget.options.orderId = value;
          canProceed = true;
          setState(() {});
        } else {
          canProceed = false;
          setState(() {});
        }
      });
    } else {
      canProceed = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (canProceed) {
      ui.platformViewRegistry.registerViewFactory("rzp-html", (int viewId) {
        html.IFrameElement element = html.IFrameElement();
        html.window.onMessage.forEach((element) async {
          log('Event Received in callback: ${element.data}');
          if (element.data == 'MODAL_CLOSED') {
            //Error
            widget.onPaymentError('MODAL_CLOSED');
          } else if (element.data.toString().contains("SUCCESS")) {
            //Success
            String paymentId = element.data.toString().split('|')[1];
            widget.onPaymentSuccess(paymentId);
          }
        });

        element.srcdoc = """<!DOCTYPE html>
      <html>
      <meta name='viewport' content='width=device-width'>
      <head><title>RazorPay Web Payment</title></head>
      <body>
      <script src='https://checkout.razorpay.com/v1/checkout.js'></script>
      <script>
            options = {
                'key': '${widget.rzpKey}',
                'order_id': '${widget.options.orderId}',
                'amount': '${widget.options.amount}', 'currency': '${widget.options.currency}',
                'name': '${widget.options.name}', 'description': '${widget.options.description}',
                'image': '${widget.options.image}', 'prefill': {'name': '${widget.options.prefill.name}', 'email': '${widget.options.prefill.email}', 'contact': '${widget.options.prefill.contact}'},
                'theme': {'color': '${widget.options.colorhex}'},
                'handler': function (response){
                    window.parent.postMessage('SUCCESS|'+response.razorpay_payment_id,'*');
                },    
              'notes': {        
                  'address': ""    
                },    
              'modal': {
                  'ondismiss': function(){
                    window.parent.postMessage('MODAL_CLOSED','*');  
                  }
              }
            };
            var rzp1 = new Razorpay(options);
            window.onload = function(e){  
                rzp1.open();
                e.preventDefault();
            }
      </script>
      </body>
      </html>""";
        element.style.border = 'none';
        element.style.border = 'none';
        element.style.width = '100%';
        element.style.height = '100%';

        return element;
      });
    }
    return Scaffold(
        body: canProceed
            ? Builder(builder: (BuildContext context) {
                return kIsWeb
                    // ignore: prefer_const_constructors
                    ? HtmlElementView(viewType: 'rzp-html')
                    : const Center(child: Text("Not Supported on this platform"));
              })
            : const Center(
                child: CircularProgressIndicator(),
              ));
  }

  Future<String?> getOrderId(RzpOptions options) async {
    if (kReleaseMode) {
      log("Generating Order Id in Release Mode is Not Recommended");
      log("------------------------------------------------------");
      log("Generating Order id in Release mode is highly unsafe, Anyone can access your Razorpay Key and Secret Key");
    }
    var orderOptions = {
      'amount': options.amount,
      'currency': "INR",
    };
    var auth = 'Basic ' + base64Encode(utf8.encode('${widget.rzpKey}:${widget.rzpSecret}'));
    Uri uri = kIsWeb
        ? Uri.parse(options.corsUrl! + "https://api.razorpay.com/v1/orders")
        : Uri.parse("https://api.razorpay.com/v1/orders");

    var client = http.Client();
    var body = json.encode(orderOptions);
    var response = await client.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': auth,
      },
      body: body,
    );
    // log(response.body.toString());
    Map resp = json.decode(response.body);

    // log(resp['error'].toString());

    try {
      if (resp['id'] == null && resp['error'] != null) {
        return null;
      } else if (resp['id'] != null) {
        return resp['id'];
      } else {
        return null;
      }
    } catch (e) {
      log(e.toString());
      return null;
    }
  }
}
