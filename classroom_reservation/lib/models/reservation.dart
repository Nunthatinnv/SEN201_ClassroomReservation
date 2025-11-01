class Reservation {
  int? reservationId;
  String seriesId;
  String roomId;
  DateTime timeStart;
  DateTime timeEnd;
  String competency;

  Reservation({
    this.reservationId,
    required this.seriesId,
    required this.roomId,
    required this.timeStart,
    required this.timeEnd,
    required this.competency,
  });

  Map<String, dynamic> toMap() {
    return {
      if (reservationId != null) 'reservation_id': reservationId,
      'series_id': seriesId,
      'room_id': roomId,
      'time_start': timeStart.toIso8601String(),
      'time_end': timeEnd.toIso8601String(),
      'competency': competency,
    };
  }

  factory Reservation.fromMap(Map<String, dynamic> map) {
    return Reservation(
      reservationId: map['reservation_id'],
      seriesId: map['series_id'],
      roomId: map['room_id'],
      timeStart: DateTime.parse(map['time_start']),
      timeEnd: DateTime.parse(map['time_end']),
      competency: map['competency'],
    );
  }
}

class ReservationInput {
  final Reservation reservation;
  final int repetition;
  final int capacity;

  ReservationInput({required this.reservation, required this.repetition, required this.capacity});
}
