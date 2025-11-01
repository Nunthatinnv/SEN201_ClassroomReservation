import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// Desktop FFI
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
// Web FFI
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    if (kIsWeb) {
      // Web initialization
      databaseFactory = databaseFactoryFfiWeb;
      return await databaseFactory.openDatabase(
        'schedool_reservation.db',
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: _onCreate,
        ),
      );
    } else if (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      // Desktop (Windows, macOS, Linux)
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;

      String path = join(await getDatabasesPath(), 'schedool_reservation.db');
      return await databaseFactory.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: _onCreate,
        ),
      );
    } else {
      // Mobile (iOS, Android)
      String path = join(await getDatabasesPath(), 'schedool_reservation.db');
      return await openDatabase(
        path,
        version: 1,
        onCreate: _onCreate,
      );
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    // Series table
    await db.execute('''
      CREATE TABLE Series(
        series_id TEXT PRIMARY KEY,
        capacity INTEGER NOT NULL,
        repetition INTEGER NOT NULL
      )
    ''');

    // Room table
    await db.execute('''
      CREATE TABLE Room(
        room_id TEXT PRIMARY KEY,
        room_name TEXT,
        capacity INTEGER NOT NULL,
        equipments TEXT
      )
    ''');

    // Reservation table
    await db.execute('''
      CREATE TABLE Reservation(
        reservation_id INTEGER PRIMARY KEY AUTOINCREMENT,
        series_id TEXT NOT NULL,
        room_id TEXT NOT NULL,
        time_start TEXT NOT NULL,
        time_end TEXT NOT NULL,
        competency TEXT NOT NULL,
        FOREIGN KEY (series_id) REFERENCES Series(series_id),
        FOREIGN KEY (room_id) REFERENCES Room(room_id)
      )
    ''');
  }
}
