import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart'; // Importe o Geolocator
import '../database/converte_dao.dart';

class Historico extends StatefulWidget {
  final List<Map<String, dynamic>> historico;
  final Future<void> Function(int id) onDelete;

  Historico({required this.historico, required this.onDelete});

  @override
  _HistoricoState createState() => _HistoricoState();
}

class _HistoricoState extends State<Historico> {
  final ConverteDAO _converteDAO = ConverteDAO();

  Future<List<Map<String, dynamic>>> _fetchHistorico() async {
    return await _converteDAO.getConversoes();
  }

  void _limparHistorico(BuildContext context) async {
    await _converteDAO.deleteConversoes;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Histórico limpo')),
    );
    setState(() {
      widget.historico.clear();
    });
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
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Valor: ${item['valor']} Resultado: ${item['resultado']}'),
                    Text('Lat: ${item['latitude']} Long: ${item['longitude']}'),
                  ],
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () async {
                    await widget.onDelete(item['id']);
                    List<Map<String, dynamic>> novoHistorico = await _fetchHistorico();
                    setState(() {
                      widget.historico.clear();
                      widget.historico.addAll(novoHistorico);
                    });
                  },
                ),
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

