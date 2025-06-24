import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseService {
  Database? _db;
  bool _isInitializing = false;

  /// Initialize the database with a single table for all STM32 readings.
  Future<void> initDB() async {
    if (_db != null) return;
    if (_isInitializing) {
      while (_db == null) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      return;
    }

    _isInitializing = true;

    final dbPath = await getDatabasesPath();
    _db = await openDatabase(
      join(dbPath, 'stm32_data.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE readings(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            timestamp TEXT,
            device TEXT,
            json_data TEXT
          )
        ''');
      },
    );

    _isInitializing = false;
  }

  /// Insert reading from any STM32 device into unified table.
  Future<void> insertReadingUnified(
      Map<String, dynamic> jsonMap, String device) async {
    if (_db == null) await initDB();

    final now = DateFormat('HH:mm:ss').format(DateTime.now());

    await _db!.transaction((txn) async {
      await txn.insert('readings', {
        'timestamp': now,
        'device': device,
        'json_data': jsonMap.toString(),
      });
    });
  }

  /// Fetch all stored readings sorted by latest first.
  Future<List<Map<String, dynamic>>> getAllReadings() async {
    if (_db == null) await initDB();
    return await _db!.query('readings', orderBy: 'id DESC');
  }
}
