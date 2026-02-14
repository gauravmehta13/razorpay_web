# Razorpay Flutter — API Reference

## Razorpay Class

### Constructor

```dart
Razorpay()
```

Creates a new Razorpay instance with its own event emitter.

### Methods

#### `open(Map<String, dynamic> options, {BuildContext? context})`

Opens the Razorpay checkout UI.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `options` | `Map<String, dynamic>` | Yes | Payment config (must include `key` and `amount`) |
| `context` | `BuildContext?` | Desktop only | **Required** for Windows, Linux, and macOS |

**Required options keys:**
- `key` — Your Razorpay API key (`rzp_test_...` or `rzp_live_...`)
- `amount` — Amount in smallest currency unit (paise for INR)

**Common optional keys:** `name`, `description`, `order_id`, `prefill` (`contact`, `email`), `theme` (`color`), `external` (`wallets`), `image`.

#### `on(String event, Function handler)`

Registers an event listener. Available events:

| Constant | Value | Handler Signature |
|----------|-------|-------------------|
| `Razorpay.EVENT_PAYMENT_SUCCESS` | `"payment.success"` | `void Function(PaymentSuccessResponse)` |
| `Razorpay.EVENT_PAYMENT_ERROR` | `"payment.error"` | `void Function(PaymentFailureResponse)` |
| `Razorpay.EVENT_EXTERNAL_WALLET` | `"payment.external_wallet"` | `void Function(ExternalWalletResponse)` |

#### `clear()`

Removes all event listeners. Call in `dispose()`.

---

## Response Models

### PaymentSuccessResponse

| Property | Type | Description |
|----------|------|-------------|
| `paymentId` | `String?` | Razorpay payment ID |
| `orderId` | `String?` | Order ID (if order-based) |
| `signature` | `String?` | Signature for server-side verification |

### PaymentFailureResponse

| Property | Type | Description |
|----------|------|-------------|
| `code` | `dynamic` | Error code (see below) |
| `message` | `String?` | Human-readable error message |

### ExternalWalletResponse

| Property | Type | Description |
|----------|------|-------------|
| `walletName` | `String?` | Name of the selected wallet (e.g. `"paytm"`) |

---

## Error Codes

| Constant | Value | Meaning |
|----------|-------|---------|
| `Razorpay.NETWORK_ERROR` | `0` | Network connectivity issue |
| `Razorpay.INVALID_OPTIONS` | `1` | Invalid options passed to `open()` |
| `Razorpay.PAYMENT_CANCELLED` | `2` | User cancelled the payment |
| `Razorpay.TLS_ERROR` | `3` | Device doesn't support TLS v1.1+ |
| `Razorpay.UNKNOWN_ERROR` | `4` | Unknown error |
