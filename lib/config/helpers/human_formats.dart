import 'package:intl/intl.dart';

class HumanFormats {
  static String number(double number) {
    int revisedNumber = int.parse(number.toString().replaceAll('.', ''));
    final formattedNumber = NumberFormat.compactCurrency(
      decimalDigits: 0,
      symbol: '',
      locale: 'en',
    ).format(revisedNumber);
    return formattedNumber;
  }
}
