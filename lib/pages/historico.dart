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
  late Position _currentPosition; // Variável para armazenar a posição atual

  // Estados para controle dos filtros
  String? _filtroMoedaOrigem;
  String? _filtroMoedaDestino;

  // Chave global para os dropdowns
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation(); // Obtém a localização atual ao iniciar
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      print("Erro ao obter localização: $e");
    }
  }

  Future<List<Map<String, dynamic>>> _fetchHistorico() async {
    List<Map<String, dynamic>> historico = await _converteDAO.getConversoes();

    // Aplicar filtros se existirem
    if (_filtroMoedaOrigem != null) {
      historico = historico.where((conversao) => conversao['moedaOrigem'] == _filtroMoedaOrigem).toList();
    }
    if (_filtroMoedaDestino != null) {
      historico = historico.where((conversao) => conversao['moedaDestino'] == _filtroMoedaDestino).toList();
    }

    return historico;
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
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Filtrar Histórico'),
                    content: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          DropdownButtonFormField<String>(
                            value: _filtroMoedaOrigem,
                            onChanged: (String? novaMoeda) {
                              setState(() {
                                _filtroMoedaOrigem = novaMoeda;
                              });
                            },
                            items: _getMoedasDropdownItems(), // Função para gerar itens do dropdown
                            hint: Text('Filtrar por Moeda de Origem'),
                          ),
                          DropdownButtonFormField<String>(
                            value: _filtroMoedaDestino,
                            onChanged: (String? novaMoeda) {
                              setState(() {
                                _filtroMoedaDestino = novaMoeda;
                              });
                            },
                            items: _getMoedasDropdownItems(), // Função para gerar itens do dropdown
                            hint: Text('Filtrar por Moeda de Destino'),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _filtroMoedaOrigem = null;
                                    _filtroMoedaDestino = null;
                                  });
                                  Navigator.pop(context);
                                },
                                child: Text('Limpar'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    Navigator.pop(context);
                                  }
                                },
                                child: Text('Aplicar'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
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
                    await widget.onDelete(item['id']); // Acesse o 'id' corretamente aqui
                    // Atualizar a interface do usuário após a exclusão
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

  List<DropdownMenuItem<String>> _getMoedasDropdownItems() {
    return [
      DropdownMenuItem<String>(
        value: 'Real',
        child: Text('Real'),
      ),
      DropdownMenuItem<String>(
        value: 'Dólar',
        child: Text('Dólar'),
      ),
      DropdownMenuItem<String>(
        value: 'Euro',
        child: Text('Euro'),
      ),
    ];
  }
}
