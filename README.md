<div align="center">

# 💳 Razorpay Flutter

### Accept payments seamlessly across all platforms

[![pub package](https://img.shields.io/pub/v/razorpay_web.svg?color=blue&style=flat-square)](https://pub.dev/packages/razorpay_web)
[![License: MIT](https://img.shields.io/badge/License-MIT-purple.svg?style=flat-square)](https://opensource.org/licenses/MIT)
[![Flutter Platform](https://img.shields.io/badge/Platform-Flutter-02569B.svg?style=flat-square&logo=flutter)](https://flutter.dev)

**Android** • **iOS** • **Web** • **Windows** • **Linux** • **macOS**

[Getting Started](#-getting-started) • [Installation](#-installation) • [Usage](#-usage) • [API Reference](#-api-reference) • [Examples](#-examples)

</div>

---

## ✨ Features

- 🌍 **True Cross-Platform** - Single API for Android, iOS, Web, Windows, Linux, and macOS
- 🎯 **Event-Driven Architecture** - Clean, reactive payment flow handling
- 🔒 **Production Ready** - Built on official Razorpay SDKs for mobile platforms
- 🪟 **Native Windows Support** - Seamless WebView integration with InAppWebView
- 🧪 **Test Mode** - Full sandbox environment support for development
- 📱 **External Wallets** - Support for Paytm, PhonePe, Google Pay, and more
- ⚡ **Zero Configuration** - Works out of the box with minimal setup

---

## ☕ Support the Development

<div align="center">

### 🏆 Help Keep This Project Alive & Thriving

As a **full-time developer** working on this plugin in my limited spare time, your support means the world! Every contribution helps me dedicate more hours to:

✨ Adding new features • 🐛 Fixing bugs faster • 📚 Improving documentation • 🚀 Supporting new platforms

<br>

<a href="https://buymeachai.ezee.li/gauravmehta13" target="_blank">
  <img src="https://img.shields.io/badge/☕_Buy_Me_A_Chai-Support_Development-orange?style=for-the-badge&logo=buy-me-a-coffee&logoColor=white" alt="Buy Me A Chai" height="50">
</a>

<br>
<br>

**🌟 If this plugin saved you hours of work, consider buying me a chai!**

*Your support directly impacts how much time I can invest in making this plugin better for everyone.*

</div>

---

## 📸 Screenshots

<div align="center">
<img src="https://raw.githubusercontent.com/gauravmehta13/razorpay_web/master/screenshots/1.jpg" height="400" alt="Android Payment Flow">
<img src="https://raw.githubusercontent.com/gauravmehta13/razorpay_web/master/screenshots/2.jpg" height="400" alt="iOS Payment Flow">
</div>

<div align="center">
<img src="https://raw.githubusercontent.com/gauravmehta13/razorpay_web/master/screenshots/3.PNG" alt="Web Payment Flow">
</div>

---

## 🚀 Getting Started

### Prerequisites

Before integrating this plugin, you'll need:

1. **Razorpay Account** - [Sign up here](https://dashboard.razorpay.com/#/access/signin)
2. **API Keys** - Generate from your [Razorpay Dashboard](https://razorpay.com/docs/payment-gateway/dashboard-guide/settings/#api-keys/)
   - Use **Test Keys** for development (no real transactions)
   - Switch to **Live Keys** for production

> 💡 **New to Razorpay?** Learn about the [payment flow](https://razorpay.com/docs/payment-gateway/payment-flow/) before integrating.

---

## 📦 Installation

Add `razorpay_web` to your `pubspec.yaml`:

```yaml
dependencies:
  razorpay_web: ^3.1.1
```

Then run:

```bash
flutter pub get
```

### Platform-Specific Setup

<details>
<summary><b>🤖 Android Setup</b></summary>

#### Minimum Requirements
- **Min SDK Version**: 19 (Android 4.4+)

Update `android/app/build.gradle`:

```gradle
android {
    defaultConfig {
        minSdkVersion 19  // Ensure this is at least 19
    }
}
```

#### ProGuard Rules (if using)

Add to your ProGuard configuration:

```proguard
-keepattributes *Annotation*
-dontwarn com.razorpay.**
-keep class com.razorpay.** {*;}
-optimizations !method/inlining/
-keepclasseswithmembers class * {
  public void onPayment*(...);
}
```

</details>

<details>
<summary><b>🍎 iOS Setup</b></summary>

#### Minimum Requirements
- **Min Deployment Target**: iOS 10.0
- **Bitcode**: Enabled

Update `ios/Podfile`:

```ruby
platform :ios, '10.0'

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ENABLE_BITCODE'] = 'YES'
      config.build_settings['SWIFT_VERSION'] = '5.0'
    end
  end
end
```

Add `use_frameworks!` if you encounter Swift header issues:

```ruby
use_frameworks!
```

Then run:

```bash
cd ios && pod install
```

</details>

<details>
<summary><b>🌐 Web Setup</b></summary>

Add the Razorpay checkout script to `web/index.html` inside the `<body>` tag:

```html
<body>
  <!-- Other content -->
  
  <script src="https://checkout.razorpay.com/v1/checkout.js"></script>
  
  <script src="main.dart.js" type="application/javascript"></script>
</body>
```

</details>

<details>
<summary><b>🪟 Windows Setup</b></summary>

#### Requirements
- **Microsoft Edge WebView2 Runtime** (pre-installed on Windows 10/11)

No additional configuration needed! The plugin uses `flutter_inappwebview` to provide a native-like payment experience.

> ⚠️ **Important**: You must pass `context` parameter when calling `open()` on Windows.

</details>

<details>
<summary><b>🐧 Linux Setup</b></summary>

Uses the same WebView implementation as Windows. No additional setup required.

</details>

<details>
<summary><b>🍏 macOS Setup</b></summary>

#### Requirements
Uses the same WebView implementation as Windows.

#### Entitlements Configuration

Add network client permission to your entitlements files:

**`macos/Runner/DebugProfile.entitlements`:**
```xml
<key>com.apple.security.network.client</key>
<true/>
```

**`macos/Runner/Release.entitlements`:**
```xml
<key>com.apple.security.network.client</key>
<true/>
```

This is required for the WebView to load Razorpay's checkout page.

> ⚠️ **Important**: You must pass `context` parameter when calling `open()` on macOS.

</details>

---

## 💻 Usage

### Quick Start

```dart
import 'package:flutter/material.dart';
import 'package:razorpay_web/razorpay_web.dart';

class PaymentScreen extends StatefulWidget {
  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late Razorpay _razorpay;

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
      'key': 'rzp_test_1DP5mmOlF5G5ag',
      'amount': 100, // amount in the smallest currency unit (paise)
      'name': 'Acme Corp.',
      'description': 'Fine T-Shirt',
      'prefill': {
        'contact': '8888888888',
        'email': 'test@razorpay.com'
      },
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options, context: context);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    print('Success: ${response.paymentId}');
    // Do something when payment succeeds
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print('Error: ${response.code} - ${response.message}');
    // Do something when payment fails
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print('External Wallet: ${response.walletName}');
    // Do something when an external wallet is selected
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Razorpay Payment')),
      body: Center(
        child: ElevatedButton(
          onPressed: openCheckout,
          child: Text('Pay Now'),
        ),
      ),
    );
  }
}
```

### Step-by-Step Guide

#### 1️⃣ Import the Package

```dart
import 'package:razorpay_web/razorpay_web.dart';
```

#### 2️⃣ Create Razorpay Instance

```dart
late Razorpay _razorpay;

@override
void initState() {
  super.initState();
  _razorpay = Razorpay();
}
```

#### 3️⃣ Attach Event Listeners

The plugin uses an event-driven architecture. Attach listeners for payment events:

```dart
_razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
_razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
_razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
```

#### 4️⃣ Define Event Handlers

```dart
void _handlePaymentSuccess(PaymentSuccessResponse response) {
  // Payment ID: response.paymentId
  // Order ID: response.orderId (if order was created)
  // Signature: response.signature (for verification)
}

void _handlePaymentError(PaymentFailureResponse response) {
  // Error code: response.code
  // Error message: response.message
}

void _handleExternalWallet(ExternalWalletResponse response) {
  // Wallet name: response.walletName
}
```

#### 5️⃣ Configure Payment Options

```dart
var options = {
  'key': 'YOUR_RAZORPAY_KEY',           // Required
  'amount': 50000,                       // Required (in paise: 50000 = ₹500)
  'name': 'Your Business Name',
  'description': 'Product Description',
  'order_id': 'order_xyz123',            // Optional: for order-based payments
  'prefill': {
    'contact': '9876543210',
    'email': 'customer@example.com'
  },
  'theme': {
    'color': '#F37254'
  }
};
```

> 📚 See [all available options](https://razorpay.com/docs/payment-gateway/integrations-guide/checkout/standard/#checkout-form)

#### 6️⃣ Open Checkout

```dart
// For Android, iOS, and Web
_razorpay.open(options);

// For Windows, Linux, and macOS (context required)
_razorpay.open(options, context: context);
```

#### 7️⃣ Clean Up

```dart
@override
void dispose() {
  super.dispose();
  _razorpay.clear(); // Remove all event listeners
}
```

---

## 🧪 Testing

Razorpay provides test credentials for sandbox testing:



### Test UPI IDs

| UPI ID | Result |
|--------|--------|
| `success@razorpay` | ✅ Payment Success |
| `failure@razorpay` | ❌ Payment Failure |

### Test Cards

| Card Number | CVV | Expiry | Result |
|-------------|-----|--------|--------|
| 4111 1111 1111 1111 | Any | Future | ✅ Success |
| 4012 8888 8888 1881 | Any | Future | ✅ Success |
| 5555 5555 5555 4444 | Any | Future | ✅ Success |

> 💡 **Tip**: Use any future expiry date and any CVV for test cards.

### Running Tests

The plugin includes comprehensive unit tests:

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/razorpay_flutter_test.dart

# Run with coverage
flutter test --coverage
```

> 📚 Learn more about [Razorpay Test Mode](https://razorpay.com/docs/payments/payments/test-card-details/)

---

## 📚 API Reference

### Razorpay Class

#### Methods

##### `open(Map<String, dynamic> options, {BuildContext? context})`

Opens the Razorpay checkout interface.

**Parameters:**
- `options` (required): Payment configuration map
  - `key` (required): Your Razorpay API key
  - `amount` (required): Amount in smallest currency unit (paise for INR)
  - `name`: Business/product name
  - `description`: Payment description
  - `order_id`: Order ID for order-based payments
  - `prefill`: Pre-filled customer details
  - `theme`: Checkout UI customization
  - [See all options](https://razorpay.com/docs/payment-gateway/integrations-guide/checkout/standard/#checkout-form)
- `context` (optional): BuildContext - **Required for Windows, Linux, and macOS**

**Example:**
```dart
_razorpay.open({
  'key': 'rzp_test_1DP5mmOlF5G5ag',
  'amount': 100,
  'name': 'Acme Corp.',
}, context: context);
```

##### `on(String event, Function handler)`

Registers an event listener for payment events.

**Parameters:**
- `event`: Event name (use constants from `Razorpay` class)
- `handler`: Callback function with appropriate response type

**Example:**
```dart
_razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, (PaymentSuccessResponse response) {
  print('Payment ID: ${response.paymentId}');
});
```

##### `clear()`

Removes all event listeners. Call this in `dispose()` to prevent memory leaks.

**Example:**
```dart
@override
void dispose() {
  _razorpay.clear();
  super.dispose();
}
```

---

### Event Names

Use these constants from the `Razorpay` class:

| Constant | Value | Description |
|----------|-------|-------------|
| `EVENT_PAYMENT_SUCCESS` | `"payment.success"` | Payment completed successfully |
| `EVENT_PAYMENT_ERROR` | `"payment.error"` | Payment failed or encountered an error |
| `EVENT_EXTERNAL_WALLET` | `"payment.external_wallet"` | External wallet was selected |

---

### Response Models

#### PaymentSuccessResponse

Emitted when payment succeeds.

| Property | Type | Description |
|----------|------|-------------|
| `paymentId` | `String?` | Unique payment identifier |
| `orderId` | `String?` | Order ID (if order-based payment) |
| `signature` | `String?` | Payment signature for verification (orders only) |

**Methods:**
- `toJson()`: Convert response to JSON map
- `toString()`: Get string representation

**Example:**
```dart
void _handlePaymentSuccess(PaymentSuccessResponse response) {
  print('Payment ID: ${response.paymentId}');
  print('Order ID: ${response.orderId}');
  print('Signature: ${response.signature}');
  
  // Convert to JSON for backend verification
  Map<String, dynamic> json = response.toJson();
}
```

#### PaymentFailureResponse

Emitted when payment fails.

| Property | Type | Description |
|----------|------|-------------|
| `code` | `int?` | Error code (see error codes below) |
| `message` | `String?` | Human-readable error message |
| `orderId` | `String?` | Order ID (if order-based payment) |
| `paymentId` | `String?` | Payment ID (if payment was initiated) |

**Methods:**
- `toJson()`: Convert response to JSON map
- `toString()`: Get string representation

**Example:**
```dart
void _handlePaymentError(PaymentFailureResponse response) {
  print('Error Code: ${response.code}');
  print('Error Message: ${response.message}');
  print('Order ID: ${response.orderId}');
  
  // Log error details
  print(response.toString());
}
```

#### ExternalWalletResponse

Emitted when user selects an external wallet.

| Property | Type | Description |
|----------|------|-------------|
| `walletName` | `String?` | Name of the selected wallet (e.g., "paytm") |

**Methods:**
- `toJson()`: Convert response to JSON map
- `toString()`: Get string representation

**Example:**
```dart
void _handleExternalWallet(ExternalWalletResponse response) {
  print('Wallet: ${response.walletName}');
  
  // Handle wallet-specific logic
  if (response.walletName == 'paytm') {
    // Paytm-specific handling
  }
}
```

---

### Error Codes

Access these constants from the `Razorpay` class:

| Constant | Value | Description |
|----------|-------|-------------|
| `NETWORK_ERROR` | `0` | Network connectivity issue |
| `INVALID_OPTIONS` | `1` | Invalid options passed to `open()` |
| `PAYMENT_CANCELLED` | `2` | User cancelled the payment |
| `TLS_ERROR` | `3` | Device doesn't support TLS v1.1 or v1.2 |
| `UNKNOWN_ERROR` | `4` | An unknown error occurred |

**Example:**
```dart
void _handlePaymentError(PaymentFailureResponse response) {
  if (response.code == Razorpay.NETWORK_ERROR) {
    print('Network error occurred');
  } else if (response.code == Razorpay.PAYMENT_CANCELLED) {
    print('User cancelled the payment');
  }
}
```

---

## 🎯 Examples

### Basic Payment

```dart
void makePayment() {
  var options = {
    'key': 'rzp_test_1DP5mmOlF5G5ag',
    'amount': 50000, // ₹500
    'name': 'Product Name',
    'description': 'Product Description',
  };
  
  _razorpay.open(options, context: context);
}
```

### Order-Based Payment

```dart
void makeOrderPayment() {
  // First, create an order on your backend
  // Then use the order_id in options
  
  var options = {
    'key': 'rzp_test_1DP5mmOlF5G5ag',
    'amount': 50000,
    'name': 'Product Name',
    'order_id': 'order_xyz123', // Order ID from backend
    'prefill': {
      'contact': '9876543210',
      'email': 'customer@example.com'
    }
  };
  
  _razorpay.open(options, context: context);
}
```

### Custom Theme

```dart
void makeStyledPayment() {
  var options = {
    'key': 'rzp_test_1DP5mmOlF5G5ag',
    'amount': 50000,
    'name': 'Your Business',
    'theme': {
      'color': '#F37254',
      'backdrop_color': '#000000'
    },
    'image': 'https://your-logo-url.com/logo.png',
  };
  
  _razorpay.open(options, context: context);
}
```

### With External Wallets

```dart
void makeWalletPayment() {
  var options = {
    'key': 'rzp_test_1DP5mmOlF5G5ag',
    'amount': 50000,
    'name': 'Product Name',
    'external': {
      'wallets': ['paytm', 'phonepe', 'googlepay']
    }
  };
  
  _razorpay.open(options, context: context);
}
```

### Complete Example

Check out the [example app](example/lib/main.dart) for a full working implementation with:
- Event listener setup
- Test UPI IDs for success/failure
- Error handling
- Platform-specific context handling

---

## 🔧 Troubleshooting

<details>
<summary><b>iOS: CocoaPods compatibility error</b></summary>

**Error:**
```
Specs satisfying the `razorpay_flutter` dependency were found, but they required a higher minimum deployment target.
```

**Solution:**
Update `ios/Podfile`:
```ruby
platform :ios, '10.0'
```

Then run:
```bash
cd ios && pod install
```

</details>

<details>
<summary><b>iOS: Swift header file not found</b></summary>

**Error:**
```
'razorpay_flutter/razorpay_flutter-Swift.h' file not found
```

**Solution:**
Add `use_frameworks!` to `ios/Podfile`:
```ruby
use_frameworks!
```

Then run:
```bash
cd ios && pod install
```

</details>

<details>
<summary><b>Android: minSdkVersion error</b></summary>

**Error:**
```
uses-sdk:minSdkVersion 16 cannot be smaller than version 19
```

**Solution:**
Update `android/app/build.gradle`:
```gradle
defaultConfig {
    minSdkVersion 19
}
```

</details>

<details>
<summary><b>Windows/Linux/macOS: Context parameter required</b></summary>

**Error:**
```
BuildContext is required for Windows/Linux/macOS platform
```

**Solution:**
Always pass `context` when calling `open()` on desktop platforms:
```dart
_razorpay.open(options, context: context);
```

The plugin uses InAppWebView for desktop platforms, which requires a BuildContext to display the payment dialog.

</details>

<details>
<summary><b>macOS: WebView blank or crashing</b></summary>

**Error:**
```
onWebContentProcessDidTerminate
```

**Solution:**
Add network client entitlement to both entitlements files:

**`macos/Runner/DebugProfile.entitlements`:**
```xml
<key>com.apple.security.network.client</key>
<true/>
```

**`macos/Runner/Release.entitlements`:**
```xml
<key>com.apple.security.network.client</key>
<true/>
```

Then rebuild your app:
```bash
flutter clean
flutter build macos
```

</details>

<details>
<summary><b>Type mismatch in event handlers</b></summary>

**Error:**
```
type 'PaymentFailureResponse' is not a subtype of type 'PaymentSuccessResponse'
```

**Solution:**
Ensure your event handlers have correct signatures:
```dart
void _handlePaymentSuccess(PaymentSuccessResponse response) { }
void _handlePaymentError(PaymentFailureResponse response) { }
void _handleExternalWallet(ExternalWalletResponse response) { }
```

</details>

<details>
<summary><b>Web: Razorpay is not defined</b></summary>

**Error:**
```
ReferenceError: Razorpay is not defined
```

**Solution:**
Ensure you've added the Razorpay script to `web/index.html`:
```html
<script src="https://checkout.razorpay.com/v1/checkout.js"></script>
```

The script must be loaded before your Flutter app initializes.

</details>

<details>
<summary><b>Payment not opening on desktop platforms</b></summary>

**Issue:**
Payment dialog doesn't appear on Windows/Linux/macOS.

**Solution:**
1. Ensure you're passing `context` parameter:
   ```dart
   _razorpay.open(options, context: context);
   ```

2. Check that `flutter_inappwebview` is properly installed:
   ```bash
   flutter pub get
   flutter clean
   flutter run
   ```

3. For Windows, verify Edge WebView2 Runtime is installed (pre-installed on Windows 10/11).

</details>

<details>
<summary><b>Memory leaks or duplicate listeners</b></summary>

**Issue:**
Event handlers being called multiple times or memory warnings.

**Solution:**
Always call `clear()` in your widget's `dispose()` method:
```dart
@override
void dispose() {
  _razorpay.clear(); // Removes all event listeners
  super.dispose();
}
```

</details>

<details>
<summary><b>Invalid options error</b></summary>

**Error:**
```
Error Code: 1 - Invalid options
```

**Solution:**
Ensure required fields are present:
```dart
var options = {
  'key': 'YOUR_KEY',      // Required
  'amount': 100,          // Required (must be integer)
  'name': 'Business Name' // Recommended
};
```

Amount must be in smallest currency unit (paise for INR):
- ₹1 = 100 paise
- ₹500 = 50000 paise

</details>

---

## 📖 Documentation

- [Razorpay Payment Gateway Docs](https://razorpay.com/docs/payment-gateway/)
- [Checkout Options Reference](https://razorpay.com/docs/payment-gateway/integrations-guide/checkout/standard/#checkout-form)
- [Android SDK Documentation](https://razorpay.com/docs/checkout/android/)
- [iOS SDK Documentation](https://razorpay.com/docs/ios/)
- [Payment Flow Guide](https://razorpay.com/docs/payment-gateway/payment-flow/)

---

## 🤝 Contributing

Contributions are welcome! Here's how you can help:

### Reporting Issues
- Check existing issues before creating a new one
- Provide detailed reproduction steps
- Include platform information (OS, Flutter version, plugin version)
- Share relevant code snippets and error messages

### Pull Requests
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass (`flutter test`)
6. Run code analysis (`flutter analyze`)
7. Format your code (`dart format .`)
8. Commit your changes (`git commit -m 'Add amazing feature'`)
9. Push to the branch (`git push origin feature/amazing-feature`)
10. Open a Pull Request

### Development Setup
```bash
# Clone the repository
git clone https://github.com/gauravmehta13/razorpay_web.git
cd razorpay_web

# Get dependencies
flutter pub get

# Run tests
flutter test

# Run example app
cd example
flutter run
```

### Code Style
- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use meaningful variable and function names
- Add comments for complex logic
- Keep functions small and focused
- Write tests for new features

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- Built on top of official [Razorpay Android](https://razorpay.com/docs/checkout/android/) and [iOS](https://razorpay.com/docs/ios/) SDKs
- Uses [flutter_inappwebview](https://pub.dev/packages/flutter_inappwebview) for Windows/Linux/macOS support
- Uses [eventify](https://pub.dev/packages/eventify) for event-driven architecture
- Inspired by the Flutter community's need for a truly cross-platform payment solution

### Contributors

Thanks to all contributors who have helped improve this plugin! 🎉

### Special Thanks

To everyone who has:
- Reported bugs and issues
- Suggested new features
- Submitted pull requests
- Supported the project financially
- Shared the plugin with others

---

## ⚠️ Disclaimer

**This is NOT an official Razorpay plugin.**

This plugin is an independent, community-driven project and is not affiliated with, endorsed by, or officially supported by Razorpay. 

**Use at your own risk.** The author and contributors:
- Are not responsible for any issues, damages, or losses arising from the use of this plugin
- Make no warranties or guarantees regarding functionality, security, or reliability
- Are not liable for any financial transactions or payment processing issues
- Recommend thorough testing in sandbox/test mode before production use

For official Razorpay integrations and support, please refer to [Razorpay's official documentation](https://razorpay.com/docs/).

---

<div align="center">

**Made with ❤️ for the Flutter community**

[Report Bug](https://github.com/gauravmehta13/razorpay_web/issues) • [Request Feature](https://github.com/gauravmehta13/razorpay_web/issues)

</div>
