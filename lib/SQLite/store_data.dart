import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseService {
  Database? _db;

  Future<void> initDB() async {
    final dbPath = await getDatabasesPath();
    _db = await openDatabase(
      join(dbPath, 'stm32_data.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE sessions(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            session_date TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE readings(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            session_id INTEGER,
            timestamp TEXT,
            json_data TEXT,
            FOREIGN KEY(session_id) REFERENCES sessions(id)
          )
        ''');
      },
    );
  }

  Future<int> _getOrCreateSession() async {
    if (_db == null) await initDB();

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final result = await _db!.query(
      'sessions',
      where: 'session_date = ?',
      whereArgs: [today],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result.first['id'] as int;
    } else {
      return await _db!.insert('sessions', {'session_date': today});
    }
  }

  Future<void> insertData(Map<String, dynamic> jsonMap) async {
    if (_db == null) await initDB();

    final sessionId = await _getOrCreateSession();
    final now = DateFormat('HH:mm:ss').format(DateTime.now());

    await _db!.insert('readings', {
      'session_id': sessionId,
      'timestamp': now,
      'json_data': jsonMap.toString(),
    });
  }

  Future<List<Map<String, dynamic>>> getAllSessions() async {
    if (_db == null) await initDB();
    return await _db!.query('sessions', orderBy: 'id DESC');
  }

  Future<List<Map<String, dynamic>>> getReadingsForSession(
      int sessionId) async {
    if (_db == null) await initDB();
    return await _db!.query(
      'readings',
      where: 'session_id = ?',
      whereArgs: [sessionId],
      orderBy: 'id ASC',
    );
  }
}
