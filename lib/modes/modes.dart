import 'package:flutter/material.dart';

ThemeData lightmode = ThemeData(
  colorScheme: ColorScheme.light(
    background: Colors.white, 
    primary: Colors.black, 
    onPrimary: Colors.grey.shade500, 
    secondary: Colors.grey.shade400, 
    onSecondary: Colors.grey.shade300, 
  )
);


ThemeData darkmode = ThemeData(
  colorScheme: ColorScheme.dark( 
    background: Colors.black,
    primary: Colors.white, 
    onPrimary: Colors.grey.shade200, 
    secondary: Colors.grey.shade100, 
    onSecondary: Colors.grey.shade50, 
  )
);