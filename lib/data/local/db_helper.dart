// lib/data/local/db_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;
  static const _dbName = 'fitquest.db';
  static const _dbVersion = 1;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), _dbName);
    return await openDatabase(path, version: _dbVersion, onCreate: _onCreate);
  }

  static Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE workouts (
        id TEXT PRIMARY KEY,
        userId TEXT,
        type TEXT,
        startTime TEXT,
        endTime TEXT,
        distanceMeters REAL,
        version INTEGER,
        synced INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE route_points (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        workoutId TEXT,
        lat REAL,
        lng REAL,
        timestamp TEXT,
        seq INTEGER
      )
    ''');
  }

  // Insert a route point (map produced by RoutePoint.toMap())
  static Future<int> insertRoutePoint(Map<String, dynamic> point) async {
    final db = await database;
    // remove 'id' key if null so AUTOINCREMENT works
    final map = Map<String, dynamic>.from(point);
    if (map['id'] == null) map.remove('id');
    return await db.insert('route_points', map, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Get route points for a workout ordered by seq
  static Future<List<Map<String, dynamic>>> getRoutePoints(String workoutId) async {
    final db = await database;
    return await db.query(
      'route_points',
      where: 'workoutId = ?',
      whereArgs: [workoutId],
      orderBy: 'seq ASC',
    );
  }

}
