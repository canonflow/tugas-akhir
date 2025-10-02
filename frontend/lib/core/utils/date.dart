import 'package:intl/intl.dart';

String dateFormatter(DateTime time) {
  final DateFormat formatter = DateFormat('dd-MM-yyyy');
  final String formatted = formatter.format(time);
  return formatted;
}