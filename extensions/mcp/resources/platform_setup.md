# Razorpay Flutter — Platform-Specific Setup

## Android

**Min SDK**: 19 (Android 4.4+)

Update `android/app/build.gradle`:

```gradle
android {
    defaultConfig {
        minSdkVersion 19
    }
}
```

**ProGuard rules** (if using code shrinking):

```proguard
-keepattributes *Annotation*
-dontwarn com.razorpay.**
-keep class com.razorpay.** {*;}
-optimizations !method/inlining/
-keepclasseswithmembers class * {
  public void onPayment*(...);
}
```

---

## iOS

**Min deployment target**: iOS 10.0

Update `ios/Podfile`:

```ruby
platform :ios, '10.0'
```

If you encounter Swift header issues, add:

```ruby
use_frameworks!
```

Then run:

```bash
cd ios && pod install
```

---

## Web

Add the Razorpay checkout script to `web/index.html` inside `<body>`, **before** your main Dart script:

```html
<script src="https://checkout.razorpay.com/v1/checkout.js"></script>
```

No other configuration needed.

---

## Windows

- Requires **Microsoft Edge WebView2 Runtime** (pre-installed on Windows 10/11).
- **`context` parameter is required** when calling `_razorpay.open(options, context: context)`.
- No additional configuration needed.

---

## Linux

- Same WebView implementation as Windows.
- **`context` parameter is required** when calling `open()`.
- No additional configuration needed.

---

## macOS

- Same WebView implementation as Windows.
- **`context` parameter is required** when calling `open()`.

Add network client permission to both entitlements files:

**`macos/Runner/DebugProfile.entitlements`** and **`macos/Runner/Release.entitlements`**:

```xml
<key>com.apple.security.network.client</key>
<true/>
```

This is required for the WebView to load Razorpay's checkout page.
