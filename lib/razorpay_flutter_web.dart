import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:razorpay_web/PayFn.dart';

/// Flutter plugin for Razorpay SDK
class RazorpayFlutterPlugin {
  // Response codes from platform

  // Payment error codes

  /// Network error code
  static const NETWORK_ERROR = 0;

  /// Invalid options error code
  static const INVALID_OPTIONS = 1;

  /// TLS error code
  static const TLS_ERROR = 3;

  /// Incompatible plugin error code
  static const INCOMPATIBLE_PLUGIN = 4;

  /// Unknown error code
  static const UNKNOWN_ERROR = 100;

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
        return await PayFn().startPayment(call.arguments);
      case 'resync':
      default:
        var defaultMap = {'status': 'Not implemented on web'};

        return defaultMap;
    }
  }
}
