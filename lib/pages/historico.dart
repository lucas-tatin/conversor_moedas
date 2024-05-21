import 'package:flutter/material.dart';
import '../database/converte_dao.dart';

class Historico extends StatelessWidget {
  final ConverteDAO _converteDAO = ConverteDAO();
  final List<Map<String, dynamic>> historico; // Adicione este parâmetro

  Historico({required this.historico, required Future<void> Function(int id) onDelete}); // Adicione este construtor

  Future<List<Map<String, dynamic>>> _fetchHistorico() async {
    return await _converteDAO.getConversoes();
  }

  void _limparHistorico(BuildContext context) async {
    await _converteDAO.deleteConversoes();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Histórico limpo')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Histórico de Conversões'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchHistorico(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar histórico'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Nenhuma conversão salva'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final item = snapshot.data![index];
              return ListTile(
                title: Text('${item['moedaOrigem']} -> ${item['moedaDestino']}'),
                subtitle: Text('Valor: ${item['valor']} Resultado: ${item['resultado']}'),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _limparHistorico(context),
        child: Icon(Icons.delete),
        tooltip: 'Limpar Histórico',
      ),
    );
  }
}
