import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hinText;
  final bool obscureText;

  const MyTextField({
    super.key, 
    required this.controller, 
    required this.hinText, 
    required this.obscureText,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderSide: 
               BorderSide(color: Theme.of(context).colorScheme.secondary),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        fillColor: Theme.of(context).colorScheme.primary,
        filled: true,
        hintText: hinText,
        hintStyle: TextStyle(
          color: Colors.grey[500],
        ),
      ),
    );
  }
}