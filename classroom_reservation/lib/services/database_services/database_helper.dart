import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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
    String dbPath = await getDatabasesPath();
    String path = join(dbPath, 'schedool_reservation.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
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

    // Reservation table with foreign keys
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
