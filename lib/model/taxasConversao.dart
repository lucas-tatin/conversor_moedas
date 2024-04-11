class ConversionRates {
  final Map<String, double> rates;

  ConversionRates({required this.rates});

  factory ConversionRates.fromJson(Map<String, dynamic> json) {
    return ConversionRates(rates: json['rates']);
  }
}