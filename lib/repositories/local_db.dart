import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDatabase {
  LocalDatabase._internal();
  static final LocalDatabase instance = LocalDatabase._internal();

  Database? _db;

  Future<void> init() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'medimanager.db');
    _db = await openDatabase(path, version: 1, onCreate: (db, v) async {
      await db.execute('''
        CREATE TABLE medicines (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          amount REAL,
          unit TEXT,
          times TEXT,
          schedule TEXT,
          totalQuantity INTEGER,
          remainingQuantity INTEGER,
          refillThreshold INTEGER,
          startDate TEXT,
          endDate TEXT
        )
      ''');
      await db.execute('''
        CREATE TABLE history (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          medicineId INTEGER,
          time TEXT,
          status TEXT
        )
      ''');
    });
  }

  Database get db => _db!;
}
