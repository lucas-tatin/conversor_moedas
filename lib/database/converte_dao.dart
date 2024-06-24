import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ConverteDAO {
  static final ConverteDAO _instance = ConverteDAO._internal();

  factory ConverteDAO() => _instance;

  ConverteDAO._internal();

  Database? _database;

  Future<Database> get _db async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'conversoes.db');
    return await openDatabase(
      path,
      version: 2, // Increment the version number
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE conversoes('
              'id INTEGER PRIMARY KEY, '
              'moedaOrigem TEXT, '
              'moedaDestino TEXT, '
              'valor REAL, '
              'resultado REAL, '
              'latitude REAL, '
              'longitude REAL, '
              'data TEXT)',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) {
        if (oldVersion < 2) {
          db.execute('ALTER TABLE conversoes ADD COLUMN latitude REAL');
          db.execute('ALTER TABLE conversoes ADD COLUMN longitude REAL');
        }
      },
    );
  }

  Future<int> saveConversao(String moedaOrigem, String moedaDestino, double valor, double resultado, double latitude, double longitude) async {
    final db = await _db;
    var now = DateTime.now().toString();
    Map<String, dynamic> row = {
      'moedaOrigem': moedaOrigem,
      'moedaDestino': moedaDestino,
      'valor': valor,
      'resultado': resultado,
      'latitude': latitude,
      'longitude': longitude,
      'data': now,
    };
    try {
      return await db.insert('conversoes', row);
    } catch (e) {
      print('Erro ao inserir conversão no banco de dados: $e');
      return -1;
    }
  }

  Future<List<Map<String, dynamic>>> getConversoes() async {
    final db = await _db;
    return await db.query('conversoes', orderBy: 'data DESC');
  }

  Future<int> deleteConversoes(int id) async {
    final db = await _db;
    return await db.delete('conversoes', where: 'id = ?', whereArgs: [id]);
  }
}
