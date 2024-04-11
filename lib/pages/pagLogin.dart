import 'package:flutter/material.dart';
import 'converteMoedas.dart'; // Importe a página de conversão de moedas

class PagLogin extends StatefulWidget {
  @override
  _PagLoginState createState() => _PagLoginState();
}

class _PagLoginState extends State<PagLogin> {
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  String _mensagem = '';

  void _realizarLogin() {
    String login = _loginController.text;
    String senha = _senhaController.text;

    if (login == '123' && senha == '123') {
      Navigator.pushReplacement( // Substitui a página atual pela próxima
        context,
        MaterialPageRoute(builder: (context) => ConverteMoedas()), // Direciona para a página de conversão de moedas
      );
    } else {
      setState(() {
        _mensagem = 'Senha incorreta, tente novamente';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login Conversor de Moedas'), // Altera o texto do título
      ),
      body: Container(
        color: Colors.yellow[100], // Fundo amarelo fraco
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                color: Colors.green[100], // Fundo verde para a linha
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  'Login Conversor', // Altera o texto da linha
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _loginController,
                decoration: InputDecoration(
                  labelText: 'Login',
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _senhaController,
                obscureText: true, // Oculta o texto digitado
                decoration: InputDecoration(
                  labelText: 'Senha',
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _realizarLogin,
                child: Text('Login'),
              ),
              SizedBox(height: 20),
              Text(
                _mensagem,
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }
}