import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {


    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("InstaPop",style: GoogleFonts.lobster(fontWeight: FontWeight.w500),),
          actions: [
            IconButton(
              onPressed: (){},
              icon: Icon(Icons.favorite_border_outlined),
            ),
            IconButton(
              onPressed: (){}, 
              icon: Icon(Icons.message_outlined)
            )
          ],
        ),
        body:Container()
      ),
    );
  }
}