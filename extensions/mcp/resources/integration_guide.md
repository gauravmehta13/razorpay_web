# Razorpay Flutter — Integration Guide

## Overview

`razorpay_web` is a Flutter plugin that provides a unified API for Razorpay payments across **Android, iOS, Web, Windows, Linux, and macOS**.

## Installation

Add to `pubspec.yaml`:

```yaml
dependencies:
  razorpay_web: ^3.1.3
```

Then run:

```bash
flutter pub get
```

> **Platform setup required** — See the platform_setup resource for Android, iOS, Web, and desktop-specific configuration.

## Quick Integration

### 1. Import

```dart
import 'package:razorpay_web/razorpay_web.dart';
```

### 2. Create Instance & Register Event Listeners

```dart
late Razorpay _razorpay;

@override
void initState() {
  super.initState();
  _razorpay = Razorpay();
  _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
  _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
  _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
}
```

### 3. Define Event Handlers

```dart
void _handlePaymentSuccess(PaymentSuccessResponse response) {
  // response.paymentId, response.orderId, response.signature
}

void _handlePaymentError(PaymentFailureResponse response) {
  // response.code, response.message
}

void _handleExternalWallet(ExternalWalletResponse response) {
  // response.walletName
}
```

### 4. Open Checkout

```dart
void openCheckout() {
  var options = {
    'key': 'YOUR_RAZORPAY_KEY',       // Required
    'amount': 50000,                   // Required — in paise (50000 = ₹500)
    'name': 'Your Business',
    'description': 'Payment Description',
    'prefill': {
      'contact': '9876543210',
      'email': 'customer@example.com',
    },
  };

  try {
    // Pass context for Windows, Linux, and macOS
    _razorpay.open(options, context: context);
  } catch (e) {
    debugPrint('Error: $e');
  }
}
```

### 5. Clean Up

```dart
@override
void dispose() {
  _razorpay.clear(); // Remove all event listeners
  super.dispose();
}
```

## Key Points

- **`key` and `amount` are required** in the options map.
- **`amount` is in the smallest currency unit** (paise for INR). So ₹500 = `50000`.
- **`context` is required on Windows, Linux, and macOS** — these platforms use InAppWebView.
- **Always call `clear()` in `dispose()`** to prevent memory leaks.
- For order-based payments, include `'order_id'` in options and verify the signature server-side.
- All payment options: https://razorpay.com/docs/payment-gateway/integrations-guide/checkout/standard/#checkout-form
