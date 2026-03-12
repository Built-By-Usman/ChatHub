import 'package:intl/intl.dart';

String transferDateAMPM(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final messageDate = DateTime(date.year, date.month, date.day);

  if (messageDate == today) {
    return DateFormat('h:mm a').format(date);          // 8:30 AM / 3:45 PM
  } else if (messageDate == yesterday) {
    return "Yesterday ${DateFormat('h:mm a').format(date)}";
  } else {
    return DateFormat('MMM d, h:mm a').format(date);   // Feb 15, 8:30 AM
  }
}

String transferTimeAMPM(DateTime date) {
  return DateFormat('h:mm a').format(date);  // sirf time → 3:45 PM
}

bool isSameDay(DateTime d1, DateTime d2) {
  return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
}

String getDateHeader(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final msgDay = DateTime(date.year, date.month, date.day);

  if (msgDay == today) return "Today";
  if (msgDay == yesterday) return "Yesterday";
  return DateFormat('MMMM d, yyyy').format(date);   // February 15, 2025
}