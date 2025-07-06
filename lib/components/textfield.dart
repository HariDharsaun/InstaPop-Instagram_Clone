import 'package:flutter/material.dart';

class MyTextfield extends StatefulWidget {
  MyTextfield({
    super.key,
    required this.controller,
    required this.hinttext,
    required this.obscureText,
    required this.showPwd
  });

  final TextEditingController controller;
  final String hinttext;
  bool obscureText;
  final bool showPwd;

  @override
  State<MyTextfield> createState() => _MyTextfieldState();
}

class _MyTextfieldState extends State<MyTextfield> {
  bool visibility = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
        border: BoxBorder.all(
          width: 0.3
        )
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: TextField(
              controller: widget.controller,
              style: TextStyle(color: Colors.black),
              cursorColor: Colors.blue,
              decoration: InputDecoration(
                // fillColor: Colors.grey.shade200,
                // filled: true,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(10),
                ),
                hintText: widget.hinttext,
                hintStyle: TextStyle(color: Colors.grey.shade600)
              ),
              obscureText: widget.obscureText,
            ),
          ),
          if(widget.showPwd)
            IconButton(
              onPressed: (){
                setState(() {
                  visibility = !visibility;
                  widget.obscureText = !widget.obscureText;
                });
              },
              icon: visibility ? Icon(Icons.visibility,color: Colors.black,) : Icon(Icons.visibility_off,color: Colors.black,),
            )
        ],
      ),
    );
  }
}
