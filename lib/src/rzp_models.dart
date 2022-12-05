class PrefillData {
  final String name;
  final String email;
  final String contact;

  const PrefillData({this.name = "", this.email = "", this.contact = ""});
}

class RzpOptions {
  String orderId;
  final String? corsUrl;
  final double amount;
  final String currency;
  final String description;
  final String image;
  final bool generateOrderId;
  final String name;
  final PrefillData prefill;
  final String colorhex;

  RzpOptions({
    this.orderId = "",
    this.generateOrderId = false,
    this.corsUrl,
    required this.amount,
    this.currency = "INR",
    this.description = "",
    this.image = "",
    this.name = "",
    this.prefill = const PrefillData(),
    this.colorhex = "",
  });
}
