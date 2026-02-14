# Razorpay Flutter — Troubleshooting

## Common Issues

### iOS: CocoaPods compatibility error

**Error:** `Specs satisfying the 'razorpay_flutter' dependency were found, but they required a higher minimum deployment target.`

**Fix:** Set `platform :ios, '10.0'` in `ios/Podfile`, then run `cd ios && pod install`.

---

### iOS: Swift header file not found

**Error:** `'razorpay_flutter/razorpay_flutter-Swift.h' file not found`

**Fix:** Add `use_frameworks!` to `ios/Podfile`, then run `cd ios && pod install`.

---

### Android: minSdkVersion error

**Error:** `uses-sdk:minSdkVersion 16 cannot be smaller than version 19`

**Fix:** Set `minSdkVersion 19` in `android/app/build.gradle` under `defaultConfig`.

---

### Desktop: BuildContext required

**Error:** `BuildContext is required for Windows/Linux/macOS platform`

**Fix:** Always pass `context` when calling `open()` on desktop:

```dart
_razorpay.open(options, context: context);
```

---

### Web: Checkout not appearing

**Cause:** Missing Razorpay script in `web/index.html`.

**Fix:** Add inside `<body>` before your main Dart script:

```html
<script src="https://checkout.razorpay.com/v1/checkout.js"></script>
```

---

## Test Credentials

Use these for sandbox/development testing (no real transactions):

### Test UPI IDs

| UPI ID | Result |
|--------|--------|
| `success@razorpay` | ✅ Payment succeeds |
| `failure@razorpay` | ❌ Payment fails |

### Test Cards

| Card Number | CVV | Expiry | Result |
|-------------|-----|--------|--------|
| `4111 1111 1111 1111` | Any | Any future date | ✅ Success |
| `5555 5555 5555 4444` | Any | Any future date | ✅ Success |
