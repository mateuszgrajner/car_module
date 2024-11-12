import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'error_code_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('car_module.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  

  Future<void> _createDB(Database db, int version) async {
    // Tworzymy tabelę dla kodów błędów
    await db.execute('''
      CREATE TABLE error_codes (
        id INTEGER PRIMARY KEY,
        code TEXT NOT NULL,
        description TEXT NOT NULL
      )
    ''');

    // Tworzymy tabelę dla dziennika odczytów
    await db.execute('''
      CREATE TABLE readings_log (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        time TEXT NOT NULL,
        error_count INTEGER NOT NULL
      )
    ''');

    // Tworzymy tabelę do przechowywania szczegółów błędów dla odczytów
    await db.execute('''
      CREATE TABLE reading_errors (
        reading_id INTEGER,
        code TEXT NOT NULL,
        description TEXT NOT NULL,
        FOREIGN KEY (reading_id) REFERENCES readings_log (id)
      )
    ''');
  }

  Future<void> insertReading(String date, String time, List<ErrorCode> errors) async {
    final db = await instance.database;

    // Wstawianie odczytu do dziennika
    final readingId = await db.insert('readings_log', {
      'date': date,
      'time': time,
      'error_count': errors.length,
    });

    // Wstawianie szczegółów błędów
    for (var error in errors) {
      await db.insert('reading_errors', {
        'reading_id': readingId,
        'code': error.code,
        'description': error.description,
      });
    }
  }

  Future<List<Map<String, dynamic>>> getAllReadingsWithErrors() async {
    final db = await instance.database;

    // Pobieranie wszystkich odczytów z błędami
    final readings = await db.query('readings_log');
    List<Map<String, dynamic>> result = [];

    for (var reading in readings) {
      final errors = await db.query(
        'reading_errors',
        where: 'reading_id = ?',
        whereArgs: [reading['id']],
      );

      result.add({
        'id': reading['id'],
        'date': reading['date'],
        'time': reading['time'],
        'errorCount': reading['error_count'],
        'errors': errors,
      });
    }

    return result;
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
