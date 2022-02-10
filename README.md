

<p align="center">
<h1>
Flutter Razorpay Web Plugin
</h1>

</p>
<p align="center">
	<i>Will be Chosen someday as a <a href="https://flutter.dev/docs/development/packages-and-plugins/favorites" rel="noopener" target="_blank">Flutter Favorite</a> by the Flutter Ecosystem Committee</i>
</p>
<p align="center">
	<a href="https://pub.dev/packages/infinite_scroll_pagination" rel="noopener" target="_blank"><img src="https://img.shields.io/pub/v/infinite_scroll_pagination.svg" alt="Pub.dev Badge"></a>
	<a href="https://github.com/EdsonBueno/infinite_scroll_pagination/actions" rel="noopener" target="_blank"><img src="https://github.com/EdsonBueno/infinite_scroll_pagination/workflows/build/badge.svg" alt="GitHub Build Badge"></a>
	<a href="https://codecov.io/gh/EdsonBueno/infinite_scroll_pagination" rel="noopener" target="_blank"><img src="https://codecov.io/gh/EdsonBueno/infinite_scroll_pagination/branch/master/graph/badge.svg?token=B0CT995PHU" alt="Code Coverage Badge"></a>
	<a href="https://gitter.im/infinite_scroll_pagination/community" rel="noopener" target="_blank"><img src="https://badges.gitter.im/infinite_scroll_pagination/community.svg" alt="Gitter Badge"></a>
	<a href="https://github.com/tenhobi/effective_dart" rel="noopener" target="_blank"><img src="https://img.shields.io/badge/style-effective_dart-40c4ff.svg" alt="Effective Dart Badge"></a>
	<a href="https://opensource.org/licenses/MIT" rel="noopener" target="_blank"><img src="https://img.shields.io/badge/license-MIT-purple.svg" alt="MIT License Badge"></a>
	<a href="https://github.com/EdsonBueno/infinite_scroll_pagination" rel="noopener" target="_blank"><img src="https://img.shields.io/badge/platform-flutter-ff69b4.svg" alt="Flutter Platform Badge"></a>
</p>

---

![image](https://user-images.githubusercontent.com/14369357/48184454-17c1bc80-e358-11e8-8821-269a30935a68.png)

A flutter plugin for razorpay integration for Web.

#### If you use this library in your app, please let me know and I'll add it to the list.


<p align="center">
<img height="400" alt="demoApp" src="https://raw.githubusercontent.com/gauravmehta13/razorpay_web/master/screenshots/1.jpg">
<img height="400" alt="demoApp" src="https://raw.githubusercontent.com/gauravmehta13/razorpay_web/master/screenshots/2.jpg">
</p>
<p align="center">
<img alt="demoApp" src="https://raw.githubusercontent.com/gauravmehta13/razorpay_web/master/screenshots/3.PNG">
</p>


### Installing
Add this in pubspec.yaml
```
  razorpay_web: 
```
### Using
```
import 'package:razorpay_web/razorpay_web.dart';
```

```
  RazorpayWeb(
        rzpKey: rzpKey, // Enter Your Razorpay Key Here
        options: RzpOptions(
          amount: 1000,
          name: "Razorpay",
          description: "Test Payment",
          image: "https://i.imgur.com/3g7nmJC.png",
          prefill: const PrefillData(
            name: "Razorpay",
            email: "rzp@gmail.com",
            contact: "9876543210",
          ),
          colorhex: "#FF0000",
        ),
        onPaymentSuccess: (String paymentId) {
          print("Payment Success");
          log(paymentId);
        },
        onPaymentError: (String error) {
          print("Payment Error");
        },
      ),

}

If payment is successful onPaymentSuccess Function will contain the payment_id from razorpay.
```


Get Cors Url for generating order id from Cors Anywhere
Github:
* https://github.com/Rob--W/cors-anywhere
