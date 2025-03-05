import 'package:razorpay_web/razorpay_web.dart';

class ExternalWalletResponse {
  String? walletName;

  ExternalWalletResponse(this.walletName);

  static ExternalWalletResponse fromMap(Map<dynamic, dynamic> map) {
    String? walletName = map["external_wallet"] as String?;
    return ExternalWalletResponse(walletName);
  }

  Jsonn get toJson => {
        'external_wallet': walletName,
      };
}
