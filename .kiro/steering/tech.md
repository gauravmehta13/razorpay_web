# Technology Stack

## Build System & Environment
- **Language**: Dart (SDK >=3.4.0 <4.0.0)
- **Framework**: Flutter (>=2.0.0)
- **Package Manager**: pub
- **Version Manager**: FVM (Flutter Version Management)

## Core Dependencies
- `eventify: ^1.0.1` - Event emitter for payment callbacks
- `package_info_plus: ^9.0.0` - Package information retrieval
- `universal_platform: ^1.1.0` - Cross-platform detection
- `web: ^1.1.1` - Web platform support
- `flutter_inappwebview: ^6.1.5` - WebView for Windows implementation

## Development Dependencies
- `flutter_test` - Flutter testing framework
- `test: ^1.26.3` - Dart testing library
- `flutter_lints: ^6.0.0` - Linting rules

## Platform-Specific Technologies

### Android
- **Language**: Kotlin
- **Build System**: Gradle
- **Min SDK**: API 19 (Android 4.4)
- **Native SDK**: Razorpay Android SDK
- **Plugin Architecture**: FlutterPlugin with ActivityAware

### iOS
- **Language**: Swift (5.0+) with Objective-C bridge
- **Build System**: CocoaPods
- **Min Deployment**: iOS 10.0
- **Native SDK**: Razorpay iOS SDK (razorpay-pod)
- **Requirements**: Bitcode enabled

### Web
- **Implementation**: JavaScript integration
- **SDK**: Razorpay Checkout.js (v1)
- **Loading**: Script tag in index.html

### Windows
- **Implementation**: InAppWebView with HTML/JavaScript
- **Requirements**: Microsoft Edge WebView2 Runtime
- **Architecture**: Dialog-based WebView wrapper

## Common Commands

### Development
```bash
# Get dependencies
flutter pub get

# Run example app
cd example
flutter run

# Run on specific platform
flutter run -d windows
flutter run -d chrome
flutter run -d android
```

### Testing
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/razorpay_flutter_test.dart

# Run with coverage
flutter test --coverage
```

### Code Quality
```bash
# Analyze code
flutter analyze

# Format code
dart format .

# Check for lints
flutter analyze --no-fatal-infos
```

### Building
```bash
# Build Android APK
flutter build apk

# Build iOS
flutter build ios

# Build web
flutter build web

# Build Windows
flutter build windows
```

### Publishing
```bash
# Dry run publish
flutter pub publish --dry-run

# Publish to pub.dev
flutter pub publish
```

## Architecture Patterns

### Plugin Architecture
- **Method Channel**: Used for Android/iOS native communication
- **Platform Interface**: Separate implementations per platform
- **Event-Based**: Asynchronous payment callbacks via EventEmitter

### Code Organization
- Platform-specific code in respective directories (android/, ios/, lib/)
- Shared Dart code in lib/
- Response models and constants in dedicated files
- Windows implementation as Dart plugin class

## Testing Strategy
- Unit tests for core Razorpay class
- Method channel mocking for platform testing
- Event listener validation
- Options validation testing
