import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'razorpay_events.dart';

/// Windows platform implementation for Razorpay using InAppWebView
class RazorpayFlutterWindows {
  static void registerWith() {
    // Register the Windows plugin
  }

  /// Opens Razorpay checkout in a WebView dialog
  Future<Map<dynamic, dynamic>> open(
    BuildContext context,
    Map<dynamic, dynamic> options,
  ) async {
    final completer = Completer<Map<dynamic, dynamic>>();

    try {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return _RazorpayWebViewDialog(
            options: options,
            onResult: (result) {
              if (Navigator.of(dialogContext).canPop()) {
                Navigator.of(dialogContext).pop();
              }
              if (!completer.isCompleted) {
                completer.complete(result);
              }
            },
            onDismiss: () {
              if (Navigator.of(dialogContext).canPop()) {
                Navigator.of(dialogContext).pop();
              }
              if (!completer.isCompleted) {
                completer.complete({
                  'type': ResponseCodes.CODE_PAYMENT_ERROR,
                  'data': {
                    'code': ResponseCodes.PAYMENT_CANCELLED,
                    'message': 'Payment processing cancelled by user',
                  },
                });
              }
            },
          );
        },
      );
    } catch (e) {
      // Handle any errors during dialog display
      if (!completer.isCompleted) {
        completer.complete({
          'type': ResponseCodes.CODE_PAYMENT_ERROR,
          'data': {
            'code': ResponseCodes.UNKNOWN_ERROR,
            'message': 'Failed to open payment dialog: $e',
          },
        });
      }
    }

    return completer.future;
  }

  /// Generates the HTML content for Razorpay checkout
  static String _generateCheckoutHtml(Map<dynamic, dynamic> options) {
    // Convert options to JSON string for JavaScript
    final optionsJson = jsonEncode(options);

    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Razorpay Checkout</title>
  <style>
    body {
      margin: 0;
      padding: 0;
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      background: #f5f5f5;
    }
  </style>
</head>
<body>
  <script>
    // Create and load Razorpay script
    var script = document.createElement('script');
    script.src = 'https://checkout.razorpay.com/v1/checkout.js';
    
    script.onload = function() {
      console.log('Razorpay script loaded');
      setTimeout(initPayment, 100);
    };
    
    script.onerror = function(e) {
      console.error('Failed to load Razorpay script');
      if (window.flutter_inappwebview) {
        window.flutter_inappwebview.callHandler('onPaymentError', JSON.stringify({
          code: 'SCRIPT_LOAD_ERROR',
          description: 'Failed to load Razorpay. Check internet connection.'
        }));
      }
    };
    
    document.head.appendChild(script);
    
    function initPayment() {
      try {
        if (typeof Razorpay === 'undefined') {
          throw new Error('Razorpay not loaded');
        }
        
        var options = $optionsJson;
        
        options.handler = function(response) {
          if (window.flutter_inappwebview) {
            window.flutter_inappwebview.callHandler('onPaymentSuccess', JSON.stringify(response));
          }
        };
        
        if (!options.modal) options.modal = {};
        options.modal.ondismiss = function() {
          if (window.flutter_inappwebview) {
            window.flutter_inappwebview.callHandler('onPaymentDismiss', '');
          }
        };
        
        var rzp = new Razorpay(options);
        
        rzp.on('payment.failed', function(response) {
          if (window.flutter_inappwebview) {
            window.flutter_inappwebview.callHandler('onPaymentError', JSON.stringify(response.error));
          }
        });
        
        rzp.open();
        
      } catch (error) {
        console.error('Initialization error:', error);
        if (window.flutter_inappwebview) {
          window.flutter_inappwebview.callHandler('onPaymentError', JSON.stringify({
            code: 'INIT_ERROR',
            description: error.message
          }));
        }
      }
    }
  </script>
</body>
</html>
''';
  }
}

/// Internal widget for displaying Razorpay WebView dialog
class _RazorpayWebViewDialog extends StatefulWidget {
  final Map<dynamic, dynamic> options;
  final Function(Map<dynamic, dynamic>) onResult;
  final VoidCallback onDismiss;

  const _RazorpayWebViewDialog({
    required this.options,
    required this.onResult,
    required this.onDismiss,
  });

  @override
  State<_RazorpayWebViewDialog> createState() => _RazorpayWebViewDialogState();
}

class _RazorpayWebViewDialogState extends State<_RazorpayWebViewDialog> {


  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: 600,
        height: 700,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            // Header with close button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Complete Payment',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    onPressed: widget.onDismiss,
                    icon: const Icon(Icons.close),
                    tooltip: 'Cancel payment',
                  ),
                ],
              ),
            ),
            // WebView
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
                child: InAppWebView(
                  initialData: InAppWebViewInitialData(
                    data: RazorpayFlutterWindows._generateCheckoutHtml(
                      widget.options,
                    ),
                    mimeType: 'text/html',
                    encoding: 'utf-8',
                    baseUrl: WebUri('https://checkout.razorpay.com'),
                  ),
                  initialSettings: InAppWebViewSettings(
                    javaScriptEnabled: true,
                    javaScriptCanOpenWindowsAutomatically: true,
                    supportMultipleWindows: true,
                    mediaPlaybackRequiresUserGesture: false,
                    allowsInlineMediaPlayback: true,
                    mixedContentMode:
                        MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
                  ),
                  onWebViewCreated: (controller) {
                    _setupJavaScriptHandlers(controller);
                  },
                  onLoadStart: (controller, url) {
                    debugPrint('WebView loading: $url');
                  },
                  onLoadStop: (controller, url) {
                    debugPrint('WebView loaded: $url');
                  },
                  onReceivedError: (controller, request, error) {
                    debugPrint('WebView error: ${error.description}');
                  },
                  onConsoleMessage: (controller, consoleMessage) {
                    debugPrint('WebView console: ${consoleMessage.message}');
                  },
                  onCreateWindow: (controller, createWindowAction) async {
                    // Razorpay opens its checkout in a popup window
                    debugPrint('Razorpay opening popup window');

                    // Show the popup WebView in a new dialog
                    if (context.mounted) {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (popupContext) {
                          return Dialog(
                            child: SizedBox(
                              width: 900,
                              height: 600,
                              child: Column(
                                children: [
                                  // Header
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    color: Colors.grey.shade100,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('Razorpay Checkout',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        IconButton(
                                          icon: const Icon(Icons.close),
                                          onPressed: () {
                                            Navigator.of(popupContext).pop();
                                            widget.onDismiss();
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Popup WebView
                                  Expanded(
                                    child: InAppWebView(
                                      windowId: createWindowAction.windowId,
                                      initialSettings: InAppWebViewSettings(
                                        javaScriptEnabled: true,
                                      ),
                                      onCloseWindow: (popupController) {
                                        debugPrint('Popup closed');
                                        Navigator.of(popupContext).pop();
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }

                    return true;
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _setupJavaScriptHandlers(InAppWebViewController controller) {
    // Handle payment success
    controller.addJavaScriptHandler(
      handlerName: 'onPaymentSuccess',
      callback: (args) {
        if (args.isNotEmpty) {
          try {
            final response = jsonDecode(args[0] as String);
            widget.onResult({
              'type': ResponseCodes.CODE_PAYMENT_SUCCESS,
              'data': {
                'razorpay_payment_id': response['razorpay_payment_id'],
                'razorpay_order_id': response['razorpay_order_id'],
                'razorpay_signature': response['razorpay_signature'],
              },
            });
          } catch (e) {
            debugPrint('Error parsing success response: $e');
            widget.onResult({
              'type': ResponseCodes.CODE_PAYMENT_SUCCESS,
              'data': {'razorpay_payment_id': args[0]},
            });
          }
        }
        return null;
      },
    );

    // Handle payment error
    controller.addJavaScriptHandler(
      handlerName: 'onPaymentError',
      callback: (args) {
        if (args.isNotEmpty) {
          try {
            final error = jsonDecode(args[0] as String);
            widget.onResult({
              'type': ResponseCodes.CODE_PAYMENT_ERROR,
              'data': {
                'code': ResponseCodes.BASE_REQUEST_ERROR,
                'message': error['description'] ?? 'Payment failed',
              },
            });
          } catch (e) {
            debugPrint('Error parsing error response: $e');
            widget.onResult({
              'type': ResponseCodes.CODE_PAYMENT_ERROR,
              'data': {
                'code': ResponseCodes.UNKNOWN_ERROR,
                'message': args[0]?.toString() ?? 'Payment failed',
              },
            });
          }
        }
        return null;
      },
    );

    // Handle payment dismiss
    controller.addJavaScriptHandler(
      handlerName: 'onPaymentDismiss',
      callback: (args) {
        widget.onDismiss();
        return null;
      },
    );
  }
}
