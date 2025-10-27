class DayCell {
  final int day;             // Day of the month (1–31)
  final String date;         // Full date string in 'yyyy-MM-dd' format
  final bool hasReservation; // Whether there is any reservation on this day

  DayCell({
    required this.day,
    required this.date,
    required this.hasReservation,
  });
}
