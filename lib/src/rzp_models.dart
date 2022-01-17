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
  String name;
  PrefillData prefill;

  RzpOptions({
    this.orderId = "",
    required this.amount,
    this.currency = "INR",
    this.description = "",
    this.name = "",
    this.prefill = const PrefillData(),
  });
}
