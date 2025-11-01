// import 'package:sqflite/sqflite.dart';
import 'database_helper.dart'; 
import '../../models/series.dart';

class SeriesServices {
  final dbHelper = DatabaseHelper();

  // ---------- Create ----------
  Future<Map<String, dynamic>> createSeries(
      String seriesId, int capacity, int repetition) async {
    final series = Series(seriesId: seriesId, capacity: capacity, repetition: repetition);

    try {
      final db = await dbHelper.database;
      await db.insert('Series', series.toMap());
      return {'success': true, 'series': series};
    } catch (error) {
      return {'success': false, 'error': error};
    }
  }

  // ---------- Read ----------
  Future<Map<String, dynamic>> getSeriesById(String seriesId) async {
    try {
      final db = await dbHelper.database;
      final result = await db.query(
        'Series',
        where: 'series_id = ?',
        whereArgs: [seriesId],
      );

      if (result.isNotEmpty) {
        return {'success': true, 'series': Series.fromMap(result.first)};
      } else {
        return {'success': true, 'series': null};
      }
    } catch (error) {
      return {'success': false, 'error': error};
    }
  }

  // ---------- Update ----------
  Future<Map<String, dynamic>> editSeriesById(
      String seriesId, int capacity, int repetition) async {
    try {
      final db = await dbHelper.database;
      int count = await db.update(
        'Series',
        {'capacity': capacity, 'repetition': repetition},
        where: 'series_id = ?',
        whereArgs: [seriesId],
      );

      if (count > 0) {
        final updatedSeries = Series(seriesId: seriesId, capacity: capacity, repetition: repetition);
        return {'success': true, 'series': updatedSeries};
      } else {
        return {'success': false, 'error': 'Series not found'};
      }
    } catch (error) {
      return {'success': false, 'error': error};
    }
  }

  // ---------- Delete ----------
  Future<Map<String, dynamic>> deleteSeriesById(String seriesId) async {
    try {
      final db = await dbHelper.database;
      int count = await db.delete(
        'Series',
        where: 'series_id = ?',
        whereArgs: [seriesId],
      );

      if (count > 0) {
        return {'success': true, 'series': Series(seriesId: seriesId, capacity: 0, repetition: 0)};
      } else {
        return {'success': false, 'error': 'Series not found'};
      }
    } catch (error) {
      return {'success': false, 'error': error};
    }
  }
}
