class PrefillData {
  final String name;
  final String email;
  final String contact;

  const PrefillData({this.name = "", this.email = "", this.contact = ""});
}

class RzpOptions {
  String orderId;
  double amount;
  String currency;
  String description;
  String image;
  String name;
  PrefillData prefill;
  String colorhex;

  RzpOptions({
    this.orderId = "",
    required this.amount,
    this.currency = "INR",
    this.description = "",
    this.image = "",
    this.name = "",
    this.prefill = const PrefillData(),
    this.colorhex = "",
  });
}
