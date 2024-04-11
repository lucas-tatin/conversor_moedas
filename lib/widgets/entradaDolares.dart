import 'package:flutter/material.dart';

class CurrencyInput extends StatelessWidget {
  final TextEditingController controller;

  const CurrencyInput({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: 'Enter amount in dollars',
      ),
    );
  }
}