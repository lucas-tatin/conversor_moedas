import 'package:flutter/material.dart';
import 'package:conversor_moedas/widgets/custom_text_field.dart';// Importe o widget aqui

class ConverteMoedas extends StatefulWidget {
  @override
  _ConverteMoedasState createState() => _ConverteMoedasState();
}

class _ConverteMoedasState extends State<ConverteMoedas> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  double _result = 0.0;
  String? _moedaOrigemSelecionada;
  String? _moedaDestinoSelecionada;
  bool _showDollarSign = false;
  bool _showError = false;
  bool _isConverting = false;
  late AnimationController _animationController;

  // Definindo as taxas de câmbio corrigidas
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

  String? _validateInput(String? value) {
    if (value == null || value.isEmpty) {
      return 'Favor, adicionar um valor para ser convertido';
    }
    if (double.tryParse(value) == null) {
      return 'Somente números são permitidos';
    }
    return null;
  }

  void _converterMoeda() {
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

    // Desabilita o botão Converter durante a conversão
    _disableConverterButton();
  }

  void _disableConverterButton() {
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _isConverting = false;
      });
    });
  }

  void _novaConversao() async {
    bool? confirmacao = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Nova Conversão'),
          content: Text('Deseja realmente sair desta conversão e iniciar uma nova?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Fecha o diálogo e retorna false
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Fecha o diálogo e retorna true
              },
              child: Text('Confirmar'),
            ),
          ],
        );
      },
    );

    if (confirmacao == true) {
      // Se o usuário confirmou, reinicie a conversão
      _animationController.stop();
      _controller.clear();
      setState(() {
        _result = 0.0;
        _moedaOrigemSelecionada = null;
        _moedaDestinoSelecionada = null;
      });
    }
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
                Navigator.of(context).pop(false); // Fecha o diálogo e retorna false
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Fecha o diálogo e retorna true
              },
              child: Text('Confirmar'),
            ),
          ],
        );
      },
    );

    if (confirmacao == true) {
      // Se o usuário confirmou, volta para a tela de login
      Navigator.pop(context, {'login': '', 'senha': ''});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Conversor de Moedas'),
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
                SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: _sair,
                  child: Text('Sair', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}