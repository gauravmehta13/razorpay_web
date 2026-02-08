## 3.1.1
- **macOS Support**: Fixed MissingPluginException for macOS platform
  - Added proper platform detection for macOS in `_resync()` method
  - Updated `open()` method to handle macOS using WebView implementation
  - macOS now uses the same InAppWebView approach as Windows and Linux
  - Added network client entitlements to example app for WebView support
  - Fixed WebView blank/crash issue by adding required macOS entitlements
- **Documentation**: Updated README and tech docs with macOS setup requirements
  - Added macOS-specific setup section with entitlements configuration
  - Added troubleshooting guide for WebView issues on macOS

## 3.1.0
- **Major Update**: Added Windows platform support using flutter_inappwebview
- **New Platforms**: Added Linux and macOS example implementations
- **Android Migration**: Converted Android implementation from Java to Kotlin
- **Code Refactoring**: Reorganized codebase structure
  - Consolidated Constants and Models into main library files
  - Added `razorpay_events.dart` for better event handling
  - Removed separate Constants and Models folders
- **Enhanced Documentation**: Updated README with Windows-specific instructions and requirements
- **Build System Updates**: 
  - Updated Android Gradle configuration
  - Added Kotlin support for Android
  - Added build configurations for all platforms
- **Example App**: Updated example app to support Windows, Linux, and macOS platforms
- **Dependencies**: Updated flutter_inappwebview to ^6.1.5 for Windows support
- **Bug Fixes**: Various performance improvements and bug fixes

## 1.5.0
- Skipped version

## 1.4.2
- Updated Description
## 1.4.1
- Bug Fix for Android
## 1.4.0
- Updated Documentation
## 1.3.9
- Minor Fixes
## 1.3.8
- Added screenshots

## 1.3.7
- Update package_info_plus to 4.0.0 to support 3.10.1 flutter version
- Synced with official razorpay plugin
## 1.3.6
- Fixed iOS build issue
- Updated Dependencies
## 1.3.5
- Bug fixes and performance improvements
- Updated Dependencies
## 1.3.3
- New Example
- Updated Dependencies


## 1.3.2

- Updated Documentation

## 1.3.1

- Added Web Support

## 1.3.0

- Standardised the events
- Minor bug fixes

## 1.2.9

- Android Native Fixes and Performance Improvements.

## 1.2.7

- Updated package to support for NULL safety.

## 1.2.6

- Updated package to support for NULL safety.

## 1.2.3

- Updated Android API key version.

## 1.2.2

- Updated Podspec to use `razorpay-pod ~> 1.1.5`

## 1.2.1

- Android bug fixes.

## 1.2.0

- Android implementation fixes added.

## 1.1.4

- Android SDK changes updated

## 1.1.3

- Updated podspec for without the version so it will always point to the latest version.
- Updated changes around Module stability related to iOS and Swift.

## 1.1.2

- Updated Podspec to use `razorpay-pod ~> 1.1.4`

## 1.1.1

- Updated podspec and build.gradle to match plugin versions

## 1.1.0

- Removed alpha status

## 1.1.0-alpha

- Added `signature` and `orderId` to `PaymentSuccessResponse` for Orders API support.
- Fixed crash due to `ActivityNotFoundException`

## 1.0.0-alpha

- Initial Release
