import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../helpers/error_code_model.dart';

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
      version: 3, // Zwiększona wersja bazy danych
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
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

    // Tworzymy tabelę do przechowywania danych na żywo (spalanie, temperatura, prędkość)
    await db.execute('''
      CREATE TABLE live_data (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        timestamp TEXT NOT NULL,
        fuel_consumption REAL,
        temperature REAL,
        speed REAL
      )
    ''');

    // Tworzymy tabelę do przechowywania logów połączeń OBD
    await db.execute('''
      CREATE TABLE connection_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        start_time TEXT NOT NULL,
        end_time TEXT,
        status TEXT NOT NULL,
        error_message TEXT
      )
    ''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE live_data (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          timestamp TEXT NOT NULL,
          fuel_consumption REAL,
          temperature REAL,
          speed REAL
        )
      ''');
    }
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE connection_logs (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          start_time TEXT NOT NULL,
          end_time TEXT,
          status TEXT NOT NULL,
          error_message TEXT
        )
      ''');
    }
  }

  // Metoda do dodawania nowych odczytów danych na żywo
  Future<void> insertLiveDataLog({
    double? fuelConsumption,
    double? temperature,
    double? speed,
  }) async {
    final db = await instance.database;
    await db.insert('live_data', {
      'timestamp': DateTime.now().toIso8601String(),
      'fuel_consumption': fuelConsumption ?? 0.0,
      'temperature': temperature ?? 0.0,
      'speed': speed ?? 0.0,
    });
    print('Dane na żywo zostały dodane do bazy');
  }

  // Metoda do obliczania średnich wartości danych na żywo
  Future<Map<String, double>> getAverageLiveData(String period) async {
    final db = await instance.database;

    // Ustal zakres czasu na podstawie przekazanego okresu
    String startDate;
    if (period == 'today') {
      startDate = DateTime.now().toIso8601String().substring(0, 10);
    } else if (period == 'week') {
      startDate = DateTime.now().subtract(Duration(days: 7)).toIso8601String();
    } else if (period == 'month') {
      startDate = DateTime.now().subtract(Duration(days: 30)).toIso8601String();
    } else {
      throw ArgumentError('Unsupported period: $period');
    }

    // Pobierz dane z tabeli live_data
    final result = await db.rawQuery('''
      SELECT AVG(fuel_consumption) AS avg_fuel, 
             AVG(temperature) AS avg_temperature, 
             AVG(speed) AS avg_speed
      FROM live_data
      WHERE timestamp >= ?
    ''', [startDate]);

    if (result.isNotEmpty) {
      return {
        'avg_fuel': (result[0]['avg_fuel'] ?? 0.0) as double,
        'avg_temperature': (result[0]['avg_temperature'] ?? 0.0) as double,
        'avg_speed': (result[0]['avg_speed'] ?? 0.0) as double,
      };
    } else {
      return {'avg_fuel': 0.0, 'avg_temperature': 0.0, 'avg_speed': 0.0};
    }
  }

  Future<List<ErrorCode>> getAllErrorCodes() async {
    final db = await instance.database;
    final result = await db.query('error_codes');

    return result.map((map) => ErrorCode.fromMap(map)).toList();
  }

  Future<int> getErrorCodeCount() async {
    final db = await instance.database;
    final result = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM error_codes'));
    return result ?? 0;
  }

  Future<void> insertReading(
      String date, String time, List<ErrorCode> errors) async {
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

  // Metoda do rejestrowania logów połączeń OBD
  Future<void> insertConnectionLog(
      {required String startTime,
      String? endTime,
      required String status,
      String? errorMessage}) async {
    final db = await instance.database;
    await db.insert('connection_logs', {
      'start_time': startTime,
      'end_time': endTime,
      'status': status,
      'error_message': errorMessage,
    });
  }

  Future<void> updateConnectionLog(int id,
      {String? endTime, String? status, String? errorMessage}) async {
    final db = await instance.database;
    await db.update(
        'connection_logs',
        {
          if (endTime != null) 'end_time': endTime,
          if (status != null) 'status': status,
          if (errorMessage != null) 'error_message': errorMessage,
        },
        where: 'id = ?',
        whereArgs: [id]);
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
