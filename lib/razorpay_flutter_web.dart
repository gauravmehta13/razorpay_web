import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:razorpay_web/PayService.dart';

/// Flutter plugin for Razorpay SDK
class RazorpayFlutterPlugin {
  // Response codes from platform

  // Payment error codes

  /// Registers plugin with registrar
  static void registerWith(Registrar registrar) {
    final MethodChannel methodChannel = MethodChannel(
        'razorpay_flutter',
        const StandardMethodCodec(),
        // ignore: deprecated_member_use
        registrar.messenger);
    final RazorpayFlutterPlugin instance = RazorpayFlutterPlugin();
    methodChannel.setMethodCallHandler(instance.handleMethodCall);
  }

  /// Handles method calls over platform channel
  Future<Map<dynamic, dynamic>> handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'open':
        return await PayService().startPayment(call.arguments);
      case 'resync':
      default:
        var defaultMap = {'status': 'Not implemented on web'};

        return defaultMap;
    }
  }
}
