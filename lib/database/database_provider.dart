import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseProvider {
  static final DatabaseProvider instance = DatabaseProvider._init();

  static Database? _database;

  DatabaseProvider._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('conversoes.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE conversoes (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      moedaOrigem TEXT,
      moedaDestino TEXT,
      valor REAL,
      resultado REAL,
      latitude REAL,
      longitude REAL
    )
    ''');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
