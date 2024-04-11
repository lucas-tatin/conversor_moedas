import 'package:flutter/material.dart';
import 'pages/pagLogin.dart'; // Importe a página de login

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App de Conversão de Moedas',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PagLogin(), // Defina a página de login como a página inicial
    );
  }
}