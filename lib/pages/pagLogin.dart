import 'package:flutter/material.dart';
import 'package:conversor_moedas/widgets/campo_login.dart'; // Importe o widget personalizado
import 'package:conversor_moedas/pages/converteMoedas.dart';

class PagLogin extends StatelessWidget {
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[100], // Fundo amarelo fraco
      appBar: AppBar(
        title: Text('Login Conversor de Moedas'), // Título centralizado
        centerTitle: true,
      ),
      body: SingleChildScrollView( // Adicionando SingleChildScrollView aqui
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CampoLogin(
                icon: Icons.person,
                hintText: 'Digite seu login',
                obscureText: false,
                controller: _loginController,
              ),
              SizedBox(height: 20.0),
              CampoLogin(
                icon: Icons.lock,
                hintText: 'Digite sua senha',
                obscureText: true,
                controller: _senhaController,
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  if (_loginController.text == '123' && _senhaController.text == '123') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ConverteMoedas()),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Usuário ou senha incorretos, favor digitar corretamente')),
                    );
                  }
                },
                child: Text('Entrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
