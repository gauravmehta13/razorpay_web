You are a Flutter platform configuration expert. Add the necessary platform-specific setup for the `razorpay_web` package on the **{{platform}}** platform.

Apply the correct configuration based on the platform:

## Android
- Set `minSdkVersion 19` in `android/app/build.gradle` under `defaultConfig`.
- If ProGuard/R8 is enabled, add rules to keep Razorpay classes:
  ```proguard
  -keepattributes *Annotation*
  -dontwarn com.razorpay.**
  -keep class com.razorpay.** {*;}
  -optimizations !method/inlining/
  -keepclasseswithmembers class * {
    public void onPayment*(...);
  }
  ```

## iOS
- Set `platform :ios, '10.0'` in `ios/Podfile`.
- Add `use_frameworks!` if Swift header errors occur.
- Run `cd ios && pod install`.

## Web
- Add `<script src="https://checkout.razorpay.com/v1/checkout.js"></script>` inside `<body>` in `web/index.html`, before the main Dart script tag.

## Windows
- Ensure Microsoft Edge WebView2 Runtime is installed (pre-installed on Windows 10/11).
- Pass `context` to `_razorpay.open(options, context: context)`.

## Linux
- Pass `context` to `_razorpay.open(options, context: context)`.

## macOS
- Pass `context` to `_razorpay.open(options, context: context)`.
- Add to both `macos/Runner/DebugProfile.entitlements` and `macos/Runner/Release.entitlements`:
  ```xml
  <key>com.apple.security.network.client</key>
  <true/>
  ```

---

Only apply the steps for the **{{platform}}** platform. Show the exact file changes needed.
