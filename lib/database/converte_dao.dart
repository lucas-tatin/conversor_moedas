import 'package:conversor_moedas/database/database_provider.dart';

class ConverteDAO {
  final DatabaseProvider _databaseProvider = DatabaseProvider.instance;

  Future<int> saveConversao(String moedaOrigem, String moedaDestino, double valor, double resultado) async {
    final db = await _databaseProvider.database;
    return await db.insert('conversoes', {
      'moedaOrigem': moedaOrigem,
      'moedaDestino': moedaDestino,
      'valor': valor,
      'resultado': resultado,
    });
  }

  Future<List<Map<String, dynamic>>> getConversoes() async {
    final db = await _databaseProvider.database;
    return await db.query('conversoes');
  }

  Future<int> deleteConversoes() async {
    final db = await _databaseProvider.database;
    return await db.delete('conversoes');
  }

  deleteConversao(int id) {}
}
