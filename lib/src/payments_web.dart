import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:razorpay_web/src/ui/ui_fake.dart' if (dart.library.html) 'package:razorpay_web/src/ui/ui_real.dart'
    as ui;
import 'package:universal_html/html.dart' as html;

import 'rzp_models.dart';

class RazorpayWeb extends StatelessWidget {
  final String rzpKey;
  final RzpOptions options;
  final Function(String) onPaymentSuccess;
  final Function(String) onPaymentError;
  // final  function(String )  onSuccess;
  const RazorpayWeb(
      {required this.rzpKey,
      required this.options,
      required this.onPaymentSuccess,
      required this.onPaymentError,
      Key? key})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    ui.platformViewRegistry.registerViewFactory("rzp-html", (int viewId) {
      html.IFrameElement element = html.IFrameElement();
      html.window.onMessage.forEach((element) async {
        log('Event Received in callback: ${element.data}');
        if (element.data == 'MODAL_CLOSED') {
          //Error
          onPaymentError('MODAL_CLOSED');
        } else if (element.data.toString().contains("SUCCESS")) {
          //Success
          String paymentId = element.data.toString().split('|')[1];
          onPaymentSuccess(paymentId);
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
                'key': '$rzpKey',
                'order_id': '${options.orderId}',
                'amount': '${options.amount}', 'currency': '${options.currency}',
                'name': '${options.name}', 'description': '${options.description}',
                'prefill': {'name': '${options.prefill.name}', 'email': '${options.prefill.email}', 'contact': '${options.prefill.contact}'},
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
    return Scaffold(body: Builder(builder: (BuildContext context) {
      return HtmlElementView(viewType: 'rzp-html');
    }));
  }
}
