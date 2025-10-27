import 'package:uuid/uuid.dart';
import 'database_services/reservation_services.dart';
import 'database_services/series_services.dart';
import '../models/reservation.dart';

const int WEEK_MS = 7 * 24 * 60 * 60 * 1000;

class Slot {
  DateTime timeStart;
  DateTime timeEnd;

  Slot({required this.timeStart, required this.timeEnd});
}

// Generate repeated weekly slots
List<Slot> generateWeeklySlots(DateTime timeStart, DateTime timeEnd, int rep) {
  List<Slot> slots = [];

  DateTime currentStart = timeStart;
  DateTime currentEnd = timeEnd;

  for (int i = 0; i < rep; i++) {
    slots.add(Slot(timeStart: currentStart, timeEnd: currentEnd));
    currentStart = currentStart.add(Duration(milliseconds: WEEK_MS));
    currentEnd = currentEnd.add(Duration(milliseconds: WEEK_MS));
  }

  return slots;
}

// Check overlap
bool isOverlap(DateTime startA, DateTime endA, DateTime startB, DateTime endB) {
  return startA.isBefore(endB) && endA.isAfter(startB);
}


Future<bool> checkConflicts(
  ReservationServices reservationServices,
  String? seriesId,
  String roomId,
  List<Slot> slots,
) async {
  if (slots.isEmpty) return false;

  for (var slot in slots) {
    DateTime slotStart = slot.timeStart;
    DateTime slotEnd = slot.timeEnd;

    DateTime dayStart = DateTime(slotStart.year, slotStart.month, slotStart.day, 0, 0, 0);
    DateTime dayEnd   = DateTime(slotStart.year, slotStart.month, slotStart.day, 23, 59, 59);

    var result = await reservationServices.getReservationsByTimeRange(
      roomId: roomId,
      startTime: dayStart,
      endTime: dayEnd,
    );

    if (!result['success']) {
      print('Error checking slot: $slot, ${result['error']}');
    } else {
      List<Reservation> reservations = result['reservations'];
      for (var res in reservations) {
        if (seriesId != null && res.seriesId == seriesId) continue;
        if (isOverlap(slotStart, slotEnd, res.timeStart, res.timeEnd)) {
          print('Conflict detected: Room $roomId already booked from ${res.timeStart} to ${res.timeEnd}');
          return true;
        }
      }
    }
  }
  return false;
}


Future<bool> addReservation(
  ReservationServices reservationServices,
  SeriesServices seriesServices,
  String roomId,
  DateTime timeStart,
  DateTime timeEnd,
  int capacity,
  int rep,
  String competency,
) async {
  List<Slot> slots = generateWeeklySlots(timeStart, timeEnd, rep);
  bool isConflict = await checkConflicts(reservationServices, null, roomId, slots);

  if (isConflict) return false;

  String seriesId = Uuid().v4(); // generate unique ID
  List<Reservation> newReservations = slots.map((slot) {
    return Reservation(
      seriesId: seriesId,
      roomId: roomId,
      timeStart: slot.timeStart,
      timeEnd: slot.timeEnd,
      competency: competency,
    );
  }).toList();

  try {
    await reservationServices.createReservations(newReservations);
    await seriesServices.createSeries(seriesId, capacity, rep);
    print('Reservations created successfully');
    return true;
  } catch (error) {
    print('Error inserting reservations: $error');
    return false;
  }
}


Future<bool> editReservation(
  ReservationServices reservationServices,
  SeriesServices seriesServices,
  String seriesId,
  String roomId,
  DateTime timeStart,
  DateTime timeEnd,
  int capacity,
  int rep,
  String competency,
) async {
  List<Slot> slots = generateWeeklySlots(timeStart, timeEnd, rep);
  bool isConflict = await checkConflicts(reservationServices, seriesId, roomId, slots);

  if (isConflict) return false;

  List<Reservation> newReservations = slots.map((slot) {
    return Reservation(
      seriesId: seriesId,
      roomId: roomId,
      timeStart: slot.timeStart,
      timeEnd: slot.timeEnd,
      competency: competency,
    );
  }).toList();

  try {
    await reservationServices.deleteReservationsBySeriesId(seriesId);
    await reservationServices.createReservations(newReservations);
    await seriesServices.editSeriesById(seriesId, capacity, rep);
    print('Reservations edited successfully');
    return true;
  } catch (error) {
    print('Error editing reservations: $error');
    return false;
  }
}


Future<bool> deleteReservation(
  ReservationServices reservationServices,
  SeriesServices seriesServices,
  String seriesId,
) async {
  try {
    await reservationServices.deleteReservationsBySeriesId(seriesId);
    await seriesServices.deleteSeriesById(seriesId);
    print('Reservations deleted successfully');
    return true;
  } catch (error) {
    print('Error deleting reservations: $error');
    return false;
  }
}

