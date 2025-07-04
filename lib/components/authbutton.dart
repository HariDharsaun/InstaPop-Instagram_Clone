import 'package:flutter/material.dart';

class AuthButton extends StatelessWidget {
  const AuthButton({super.key,required this.name, required this.function});

  final String name;
  final VoidCallback function;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: function,
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(18),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(10)
        ),
        child: Text(name,style: TextStyle(color: Colors.white),),
      ),
    );
  }
}