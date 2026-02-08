# Project Structure

## Root Directory Layout

```
razorpay_web/
├── .dart_tool/          # Dart tooling cache
├── .fvm/                # Flutter Version Management
├── .kiro/               # Kiro AI assistant configuration
│   └── steering/        # Project steering documents
├── android/             # Android platform implementation
├── ios/                 # iOS platform implementation
├── lib/                 # Main Dart library code
├── example/             # Example Flutter application
├── test/                # Unit tests
├── screenshots/         # Documentation images
├── pubspec.yaml         # Package configuration
└── analysis_options.yaml # Linting configuration
```

## Library Structure (`lib/`)

### Core Files
- `razorpay_web.dart` - Main plugin class and public API
  - Razorpay class with open(), on(), clear() methods
  - PaymentSuccessResponse, PaymentFailureResponse, ExternalWalletResponse models
  - Platform detection and method channel communication
  
- `razorpay_events.dart` - Event names and response codes
  - RazorpayEvents constants (EVENT_PAYMENT_SUCCESS, etc.)
  - ResponseCodes constants (error codes, status codes)

- `razorpay_flutter_windows.dart` - Windows platform implementation
  - RazorpayFlutterWindows class
  - InAppWebView-based checkout dialog
  - HTML generation for Razorpay checkout
  - JavaScript handler setup

- `flutter.jar` - Binary dependency (if needed)

## Android Structure (`android/`)

```
android/
├── src/main/
│   ├── kotlin/com/razorpay/razorpay_flutter/
│   │   ├── RazorpayFlutterPlugin.kt    # Main plugin class
│   │   └── RazorpayDelegate.kt         # Payment handling logic
│   └── AndroidManifest.xml
├── build.gradle                         # Android build configuration
└── gradle/                              # Gradle wrapper
```

### Key Components
- **RazorpayFlutterPlugin**: FlutterPlugin + ActivityAware implementation
- **RazorpayDelegate**: Handles Razorpay SDK integration and activity results
- **Method Channel**: "razorpay_flutter" for Flutter-Android communication

## iOS Structure (`ios/`)

```
ios/
├── Classes/
│   ├── RazorpayFlutterPlugin.h         # Objective-C header
│   ├── RazorpayFlutterPlugin.m         # Objective-C implementation
│   ├── SwiftRazorpayFlutterPlugin.swift # Swift plugin class
│   └── RazorpayDelegate.swift          # Payment handling
├── Assets/                              # iOS assets
└── razorpay_web.podspec                # CocoaPods specification
```

### Key Components
- **SwiftRazorpayFlutterPlugin**: Main Swift plugin class
- **RazorpayDelegate**: Razorpay SDK integration
- **Podspec**: Defines iOS dependencies and configuration

## Example App Structure (`example/`)

```
example/
├── lib/
│   └── main.dart                       # Demo application
├── android/                            # Android example config
├── ios/                                # iOS example config
├── web/                                # Web example config
├── windows/                            # Windows example config
├── linux/                              # Linux example config
├── macos/                              # macOS example config
└── pubspec.yaml                        # Example dependencies
```

### Example App Features
- Payment initialization demo
- Event listener setup
- Test UPI IDs for success/failure scenarios
- Platform-specific context handling (Windows)

## Test Structure (`test/`)

```
test/
└── razorpay_flutter_test.dart          # Unit tests
```

### Test Coverage
- Method channel mocking
- Options validation
- Event emission testing
- Error handling validation

## Configuration Files

### Root Level
- `pubspec.yaml` - Package metadata, dependencies, platform plugin configuration
- `analysis_options.yaml` - Dart analyzer and linter rules
- `CHANGELOG.md` - Version history
- `README.md` - Documentation
- `LICENSE` - MIT license

### Analysis Configuration
- Uses `package:flutter_lints/flutter.yaml`
- Disables `constant_identifier_names` rule
- Ignores `file_names` errors

## Platform Plugin Registration

Defined in `pubspec.yaml`:
```yaml
flutter:
  plugin:
    platforms:
      android:
        package: com.razorpay.razorpay_flutter
        pluginClass: RazorpayFlutterPlugin
      ios:
        pluginClass: RazorpayFlutterPlugin
      web:
        pluginClass: RazorpayFlutterPlugin
        fileName: razorpay_flutter_web.dart
      windows:
        dartPluginClass: RazorpayFlutterWindows
```

## Naming Conventions

### Files
- Dart files: snake_case (e.g., `razorpay_web.dart`)
- Kotlin files: PascalCase (e.g., `RazorpayFlutterPlugin.kt`)
- Swift files: PascalCase (e.g., `RazorpayDelegate.swift`)

### Classes
- PascalCase for all classes (e.g., `Razorpay`, `PaymentSuccessResponse`)

### Constants
- SCREAMING_SNAKE_CASE for public constants (e.g., `EVENT_PAYMENT_SUCCESS`)
- Prefixed with underscore for private constants (e.g., `_CODE_PAYMENT_SUCCESS`)

### Methods
- camelCase for all methods (e.g., `openCheckout`, `handlePaymentSuccess`)

## Import Organization
1. Dart SDK imports
2. Flutter imports
3. Third-party package imports
4. Relative imports
5. Export statements at the end
