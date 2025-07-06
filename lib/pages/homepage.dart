import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instapop_/authentication/auth.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {

  void logout()async{
    AuthService _auth = AuthService();
    await _auth.logout(); 
  }

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
              onPressed: (){
                logout();
                Navigator.pushReplacementNamed(context, '/login');
              }, 
              icon: Icon(Icons.logout)
            )
          ],
        ),
      ),
    );
  }
}