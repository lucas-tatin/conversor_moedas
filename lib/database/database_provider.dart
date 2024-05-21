import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseProvider {
  static final DatabaseProvider _instance = DatabaseProvider._internal();
  DatabaseProvider._internal();
  static DatabaseProvider get instance => _instance;

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'conversoes.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE conversoes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        moedaOrigem TEXT,
        moedaDestino TEXT,
        valor REAL,
        resultado REAL
      )
    ''');
  }
}
