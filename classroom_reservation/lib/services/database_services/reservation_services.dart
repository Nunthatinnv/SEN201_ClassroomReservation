import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';
import '../../models/reservation.dart';

class ReservationServices {
  final dbHelper = DatabaseHelper();

  // ---------- Create ----------
  Future<Map<String, dynamic>> createReservations(List<Reservation> reservations) async {
    try {
      final db = await dbHelper.database;
      Batch batch = db.batch();

      for (var r in reservations) {
        batch.insert('Reservation', r.toMap());
      }

      final results = await batch.commit(noResult: true);
      return {'success': true, 'created': reservations.length};
    } catch (error) {
      return {'success': false, 'error': error};
    }
  }

  // ---------- Read ----------
  Future<Map<String, dynamic>> getAllReservations() async {
    try {
      final db = await dbHelper.database;

      final result = await db.query('Reservation'); // fetch all rows
      
      List<Reservation> reservations = result.map((r) => Reservation.fromMap(r)).toList();
      
      print('Query result: $reservations');
      return {'success': true, 'reservations': reservations};
    } catch (error) {
      // print('Error fetching reservations: $error');
      return {'success': true, 'error': error};
    }
  }



  Future<Map<String, dynamic>> getReservationsBySeriesId(String seriesId) async {
    try {
      final db = await dbHelper.database;
      final result = await db.query(
        'Reservation',
        where: 'series_id = ?',
        whereArgs: [seriesId],
      );
      List<Reservation> reservations = result.map((r) => Reservation.fromMap(r)).toList();
      return {'success': true, 'reservations': reservations};
    } catch (error) {
      return {'success': false, 'error': error};
    }
  }

  Future<Map<String, dynamic>> getReservationsByTimeRange(
      {String? roomId, required DateTime startTime, required DateTime endTime}) async {
    try {
      final db = await dbHelper.database;

      String whereClause =
          'time_start < ? AND time_end > ?'; // overlap condition
      List<dynamic> whereArgs = [endTime.toIso8601String(), startTime.toIso8601String()];

      if (roomId != null) {
        whereClause += ' AND room_id = ?';
        whereArgs.add(roomId);
      }

      final result = await db.query(
        'Reservation',
        where: whereClause,
        whereArgs: whereArgs,
      );

      List<Reservation> reservations = result.map((r) => Reservation.fromMap(r)).toList();
      return {'success': true, 'reservations': reservations};
    } catch (error) {
      return {'success': false, 'error': error};
    }
  }

  // ---------- Delete ----------
  Future<Map<String, dynamic>> deleteReservationById(int reservationId) async {
    try {
      final db = await dbHelper.database;
      int count = await db.delete(
        'Reservation',
        where: 'reservation_id = ?',
        whereArgs: [reservationId],
      );

      if (count > 0) {
        return {'success': true, 'reservation': Reservation(reservationId: reservationId, seriesId: '', roomId: '', timeStart: DateTime.now(), timeEnd: DateTime.now(), competency: '')};
      } else {
        return {'success': false, 'error': 'Reservation not found'};
      }
    } catch (error) {
      return {'success': false, 'error': error};
    }
  }

  Future<Map<String, dynamic>> deleteReservationsBySeriesId(String seriesId) async {
    try {
      final db = await dbHelper.database;
      int count = await db.delete(
        'Reservation',
        where: 'series_id = ?',
        whereArgs: [seriesId],
      );

      return {'success': true, 'deleted': count};
    } catch (error) {
      return {'success': false, 'error': error};
    }
  }
}
