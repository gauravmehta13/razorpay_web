import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'razorpay_events.dart';

/// WebView platform implementation for Razorpay (Windows, macOS, Linux)
class RazorpayFlutterWebView {
  static void registerWith() {
    // Register the WebView plugin
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
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <title>Razorpay Checkout</title>
  <style>
    * {
      margin: 0;
      padding: 0;
      box-sizing: border-box;
    }
    
    html, body {
      width: 100%;
      height: 100%;
      overflow: hidden;
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
      background: transparent;
      -webkit-font-smoothing: antialiased;
      -moz-osx-font-smoothing: grayscale;
    }
    
    body {
      display: flex;
      align-items: center;
      justify-content: center;
    }
    
    #loading {
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      gap: 16px;
      color: #666;
    }
    
    .spinner {
      width: 40px;
      height: 40px;
      border: 3px solid #f0f0f0;
      border-top-color: #528ff0;
      border-radius: 50%;
      animation: spin 0.8s linear infinite;
    }
    
    @keyframes spin {
      to { transform: rotate(360deg); }
    }
    
    /* Override Razorpay modal styles for better integration */
    .razorpay-container {
      position: fixed !important;
      top: 0 !important;
      left: 0 !important;
      width: 100% !important;
      height: 100% !important;
      z-index: 999999 !important;
    }
  </style>
</head>
<body>
  <div id="loading">
    <div class="spinner"></div>
    <div>Loading payment...</div>
  </div>
  
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
      document.getElementById('loading').innerHTML = '<div style="color: #e74c3c; text-align: center;"><div style="font-size: 48px; margin-bottom: 16px;">⚠️</div><div>Failed to load payment gateway</div><div style="font-size: 14px; margin-top: 8px; color: #999;">Please check your internet connection</div></div>';
      
      window.location.href = 'razorpay://error?code=SCRIPT_LOAD_ERROR&description=' + encodeURIComponent('Failed to load Razorpay');
    };
    
    document.head.appendChild(script);
    
    function initPayment() {
      try {
        if (typeof Razorpay === 'undefined') {
          throw new Error('Razorpay not loaded');
        }
        
        var options = $optionsJson;
        
        // Configure modal to be embedded
        if (!options.modal) options.modal = {};
        options.modal.backdropclose = false;
        options.modal.escape = false;
        
        options.handler = function(response) {
          console.log('Payment success:', response);
          var params = 'razorpay_payment_id=' + encodeURIComponent(response.razorpay_payment_id || '');
          if (response.razorpay_order_id) {
            params += '&razorpay_order_id=' + encodeURIComponent(response.razorpay_order_id);
          }
          if (response.razorpay_signature) {
            params += '&razorpay_signature=' + encodeURIComponent(response.razorpay_signature);
          }
          window.location.href = 'razorpay://success?' + params;
        };
        
        options.modal.ondismiss = function() {
          console.log('Payment dismissed');
          window.location.href = 'razorpay://dismiss';
        };
        
        var rzp = new Razorpay(options);
        
        rzp.on('payment.failed', function(response) {
          console.log('Payment failed:', response);
          var error = response.error || {};
          var params = 'code=' + encodeURIComponent(error.code || 'UNKNOWN_ERROR');
          params += '&description=' + encodeURIComponent(error.description || 'Payment failed');
          window.location.href = 'razorpay://error?' + params;
        });
        
        // Hide loading indicator
        document.getElementById('loading').style.display = 'none';
        
        // Open Razorpay checkout
        rzp.open();
        
      } catch (error) {
        console.error('Initialization error:', error);
        document.getElementById('loading').innerHTML = '<div style="color: #e74c3c; text-align: center;"><div style="font-size: 48px; margin-bottom: 16px;">⚠️</div><div>Payment initialization failed</div><div style="font-size: 14px; margin-top: 8px; color: #999;">' + error.message + '</div></div>';
        
        window.location.href = 'razorpay://error?code=INIT_ERROR&description=' + encodeURIComponent(error.message);
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
  void _handleCustomSchemeUrl(String url) {
    final uri = Uri.parse(url);
    
    if (uri.host == 'success') {
      // Payment success
      final paymentId = uri.queryParameters['razorpay_payment_id'] ?? '';
      final orderId = uri.queryParameters['razorpay_order_id'];
      final signature = uri.queryParameters['razorpay_signature'];
      
      widget.onResult({
        'type': ResponseCodes.CODE_PAYMENT_SUCCESS,
        'data': {
          'razorpay_payment_id': paymentId,
          if (orderId != null) 'razorpay_order_id': orderId,
          if (signature != null) 'razorpay_signature': signature,
        },
      });
    } else if (uri.host == 'error') {
      // Payment error
      final code = uri.queryParameters['code'] ?? ResponseCodes.UNKNOWN_ERROR;
      final description = uri.queryParameters['description'] ?? 'Payment failed';
      
      widget.onResult({
        'type': ResponseCodes.CODE_PAYMENT_ERROR,
        'data': {
          'code': code,
          'message': description,
        },
      });
    } else if (uri.host == 'dismiss') {
      // Payment dismissed
      widget.onDismiss();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final dialogWidth = screenSize.width > 500 ? 480.0 : screenSize.width - 32;
    final dialogHeight = screenSize.height > 750 ? 720.0 : screenSize.height - 80;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: dialogWidth,
        height: dialogHeight,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: InAppWebView(
            initialData: InAppWebViewInitialData(
              data: RazorpayFlutterWebView._generateCheckoutHtml(
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
              mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
              transparentBackground: true,
            ),
            shouldOverrideUrlLoading: (controller, navigationAction) async {
              final url = navigationAction.request.url.toString();
              debugPrint('URL navigation: $url');
              
              // Intercept custom scheme URLs for payment callbacks
              if (url.startsWith('razorpay://')) {
                _handleCustomSchemeUrl(url);
                return NavigationActionPolicy.CANCEL;
              }
              
              return NavigationActionPolicy.ALLOW;
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
                    final popupWidth = screenSize.width > 500 ? 480.0 : screenSize.width - 32;
                    final popupHeight = screenSize.height > 750 ? 720.0 : screenSize.height - 80;

                    return Dialog(
                      backgroundColor: Colors.transparent,
                      insetPadding: const EdgeInsets.all(16),
                      child: Container(
                        width: popupWidth,
                        height: popupHeight,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: InAppWebView(
                            windowId: createWindowAction.windowId,
                            initialSettings: InAppWebViewSettings(
                              javaScriptEnabled: true,
                              transparentBackground: true,
                            ),
                            onCloseWindow: (popupController) {
                              debugPrint('Popup closed');
                              Navigator.of(popupContext).pop();
                            },
                          ),
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
    );
  }
}
