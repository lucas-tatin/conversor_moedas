import 'package:flutter/material.dart';
import 'package:conversor_moedas/widgets/custom_text_field.dart';
import '../database/converte_dao.dart';
import 'historico.dart';
import 'package:geolocator/geolocator.dart';

class ConverteMoedas extends StatefulWidget {
  @override
  _ConverteMoedasState createState() => _ConverteMoedasState();
}

class _ConverteMoedasState extends State<ConverteMoedas> with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  double _result = 0.0;
  String? _moedaOrigemSelecionada;
  String? _moedaDestinoSelecionada;
  bool _showDollarSign = false;
  bool _showError = false;
  bool _isConverting = false;
  late AnimationController _animationController;
  final ConverteDAO _converteDAO = ConverteDAO();

  final Map<String, double> _taxasDeCambio = {
    'Real': 1.0,
    'Dólar': 0.20,
    'Euro': 0.1838235294117647,
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Serviço de localização desativado.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Permissão de localização negada.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Permissão de localização permanentemente negada.');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> _salvarConversao(double valor, double resultado) async {
    String moedaOrigem = _moedaOrigemSelecionada ?? '';
    String moedaDestino = _moedaDestinoSelecionada ?? '';
    try {
      Position position = await _getCurrentLocation();
      int result = await _converteDAO.saveConversao(moedaOrigem, moedaDestino, valor, resultado, position.latitude, position.longitude);
      if (result == -1) {
        print('Falha ao salvar conversão no banco de dados.');
      }
    } catch (e) {
      print('Erro ao salvar conversão: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _recuperarHistorico() async {
    return await _converteDAO.getConversoes();
  }

  Future<void> _excluirConversao(int id) async {
    await _converteDAO.deleteConversoes(id);
  }

  void _converterMoeda() async {
    setState(() {
      _showError = false;
    });

    double valor = double.tryParse(_controller.text) ?? 0.0;

    if (valor == 0.0) {
      setState(() {
        _showError = true;
      });
      return;
    }

    if (_moedaOrigemSelecionada == null || _moedaDestinoSelecionada == null) {
      setState(() {
        _showError = true;
      });
      return;
    }

    double taxaOrigem = _taxasDeCambio[_moedaOrigemSelecionada!] ?? 1.0;
    double taxaDestino = _taxasDeCambio[_moedaDestinoSelecionada!] ?? 1.0;
    _result = valor / taxaOrigem * taxaDestino;
    setState(() {
      _isConverting = true;
      _showDollarSign = true;
    });

    _animationController.repeat();

    try {
      await _salvarConversao(valor, _result);
    } catch (e) {
      print('Erro ao converter moeda: $e');
    } finally {
      _disableConverterButton();
    }
  }

  void _disableConverterButton() {
    _animationController.stop();
    setState(() {
      _isConverting = false;
    });
  }

  void _novaConversao() {
    _animationController.stop();
    _controller.clear();
    setState(() {
      _result = 0.0;
      _moedaOrigemSelecionada = null;
      _moedaDestinoSelecionada = null;
    });
  }

  void _sair() async {
    bool? confirmacao = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Sair'),
          content: Text('Você realmente deseja sair do Conversor de Moedas?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('Confirmar'),
            ),
          ],
        );
      },
    );

    if (confirmacao == true) {
      Navigator.pop(context, {'login': '', 'senha': ''});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Conversor de Moedas'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () async {
              List<Map<String, dynamic>> historico = await _recuperarHistorico();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Historico(historico: historico, onDelete: _excluirConversao)),
              );
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.yellow[100],
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Moeda de Origem'),
                    Text('Moeda de Destino'),
                  ],
                ),
                SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    DropdownButton<String>(
                      value: _moedaOrigemSelecionada,
                      onChanged: (String? novaMoeda) {
                        setState(() {
                          _moedaOrigemSelecionada = novaMoeda;
                        });
                      },
                      items: _taxasDeCambio.keys.map((String moeda) {
                        return DropdownMenuItem<String>(
                          value: moeda,
                          child: Text(moeda),
                        );
                      }).toList(),
                      hint: Text(
                        _moedaOrigemSelecionada == null ? 'Selecionar' : '',
                        style: TextStyle(color: _moedaOrigemSelecionada == null ? Colors.grey[400] : Colors.black),
                      ),
                    ),
                    DropdownButton<String>(
                      value: _moedaDestinoSelecionada,
                      onChanged: (String? novaMoeda) {
                        setState(() {
                          _moedaDestinoSelecionada = novaMoeda;
                        });
                      },
                      items: _taxasDeCambio.keys.map((String moeda) {
                        return DropdownMenuItem<String>(
                          value: moeda,
                          child: Text(moeda),
                        );
                      }).toList(),
                      hint: Text(
                        _moedaDestinoSelecionada == null ? 'Selecionar' : '',
                        style: TextStyle(color: _moedaDestinoSelecionada == null ? Colors.grey[400] : Colors.black),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.0),
                CustomTextField(
                  controller: _controller,
                  icon: Icons.attach_money,
                ),
                SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: _moedaOrigemSelecionada != null &&
                      _moedaDestinoSelecionada != null &&
                      !_isConverting
                      ? _converterMoeda
                      : null,
                  child: Text('Converter'),
                ),
                SizedBox(height: 20.0),
                AnimatedOpacity(
                  opacity: _showDollarSign ? 1.0 : 0.0,
                  duration: Duration(milliseconds: 500),
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Text(
                        '\$\$',
                        style: TextStyle(
                          fontSize: 20.0,
                          color: Colors.green,
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 20.0),
                Text(
                  '${_result.toStringAsFixed(2)} ${_moedaDestinoSelecionada?.toLowerCase() ?? ""}',
                  style: TextStyle(fontSize: 20.0),
                ),
                SizedBox(height: 20.0),
                Visibility(
                  visible: _showError,
                  child: Text(
                    'Selecione as moedas de origem e destino e insira um valor válido',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: _novaConversao,
                  child: Text('Nova Conversão'),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _sair,
        child: Icon(Icons.exit_to_app),
        tooltip: 'Sair',
      ),
    );
  }
}
