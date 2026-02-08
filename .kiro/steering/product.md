# Product Overview

## Razorpay Flutter Plugin

A cross-platform Flutter plugin that integrates Razorpay payment gateway for mobile and desktop applications.

### Purpose
Provides a unified API for accepting payments through Razorpay across Android, iOS, Web, Windows, Linux, and macOS platforms.

### Key Features
- Multi-platform payment processing (Android, iOS, Web, Windows, Linux, macOS)
- Event-based payment flow handling (success, error, external wallet)
- Native SDK wrappers for Android and iOS
- WebView-based implementation for Windows, Linux, and macOS using InAppWebView
- Web implementation using Razorpay's JavaScript checkout
- Test mode support for sandbox testing

### Payment Flow
1. Initialize Razorpay instance
2. Attach event listeners for payment events
3. Configure payment options (key, amount, description, etc.)
4. Open checkout interface
5. Handle payment response via event callbacks

### Target Users
Flutter developers integrating payment processing into their applications using Razorpay as the payment gateway provider.
