// import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';
import '../../models/room.dart';
import 'reservation_services.dart';

class RoomServices {
  final dbHelper = DatabaseHelper();


  // ---------- Create ----------
  Future<Map<String, dynamic>> createRoom(Room room) async {
    try {
      final db = await dbHelper.database;
      await db.insert('Room', room.toMap());
      return {'success': true, 'room': room};
    } catch (error) {
      return {'success': false, 'error': error};
    }
  }

  // ---------- Read ----------
  Future<Map<String, dynamic>> getAllRooms() async {
    try {
      final db = await dbHelper.database;
      final result = await db.query('Room');
      List<Room> rooms = result.map((r) => Room.fromMap(r)).toList();
      return {'success': true, 'rooms': rooms};
    } catch (error) {
      return {'success': false, 'error': error};
    }
  }

  Future<Map<String, dynamic>> getRoomById(String roomId) async {
    try {
      final db = await dbHelper.database;
      final result = await db.query(
        'Room',
        where: 'room_id = ?',
        whereArgs: [roomId],
      );
      if (result.isNotEmpty) {
        return {'success': true, 'room': Room.fromMap(result.first)};
      } else {
        return {'success': true, 'room': null};
      }
    } catch (error) {
      return {'success': false, 'error': error};
    }
  }

  // ---------- Update ----------
  Future<Map<String, dynamic>> updateRoom(String roomId, Map<String, dynamic> data) async {
    try {
      final db = await dbHelper.database;
      int count = await db.update(
        'Room',
        data,
        where: 'room_id = ?',
        whereArgs: [roomId],
      );
      if (count > 0) {
        final updatedRoom = Room(
          roomId: roomId,
          roomName: data['room_name'],
          capacity: data['capacity'] ?? 0,
          equipments: data['equipments'],
        );
        return {'success': true, 'room': updatedRoom};
      } else {
        return {'success': false, 'error': 'Room not found'};
      }
    } catch (error) {
      return {'success': false, 'error': error};
    }
  }

  // ---------- Delete ----------
  Future<Map<String, dynamic>> deleteRoom(String roomId) async {
    try {
      final db = await dbHelper.database;
      int count = await db.delete('Room', where: 'room_id = ?', whereArgs: [roomId]);
      if (count > 0) {
        return {'success': true, 'room': Room(roomId: roomId, roomName: null, capacity: 0)};
      } else {
        return {'success': false, 'error': 'Room not found'};
      }
    } catch (error) {
      return {'success': false, 'error': error};
    }
  }

  // ---------- Recommended Rooms ----------
  Future<Map<String, dynamic>> getRecommendedRooms(
      DateTime timeStart,
      DateTime timeEnd,
      int repetition,
      int capacity) async {
    try {
      final db = await dbHelper.database;

      // 1. Get all rooms with sufficient capacity
      final suitableRoomsResult = await db.query(
        'Room',
        where: 'capacity >= ?',
        whereArgs: [capacity],
      );
      List<Room> suitableRooms = suitableRoomsResult.map((r) => Room.fromMap(r)).toList();
      if (suitableRooms.isEmpty) return {'success': true, 'rooms': []};

      // 2. Check booked rooms for overlapping reservations
      final reservationServices = ReservationServices();
      Set<String> bookedRoomIds = {};

      for (int i = 0; i < repetition; i++) {
        // You should implement generateWeeklySlots equivalent here
        final slotStart = timeStart.add(Duration(days: 7 * i));
        final slotEnd = timeEnd.add(Duration(days: 7 * i));

        var reservationsResult =
            await reservationServices.getReservationsByTimeRange(startTime: slotStart, endTime:  slotEnd);
        if (!reservationsResult['success']) return reservationsResult;

        for (var r in reservationsResult['reservations']) {
          bookedRoomIds.add(r.roomId);
        }
      }

      // 3. Filter available rooms
      List<Room> availableRooms =
          suitableRooms.where((room) => !bookedRoomIds.contains(room.roomId)).toList();

      return {'success': true, 'rooms': availableRooms};
    } catch (error) {
      return {'success': false, 'error': error};
    }
  }
}
