import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:instapop_/firebase_options.dart';
import 'package:instapop_/modes/modes.dart';
import 'package:instapop_/pages/homepage.dart';
import 'package:instapop_/pages/loginpage.dart';
import 'package:instapop_/pages/pagestack.dart';
import 'package:instapop_/pages/profile_setup.dart';
import 'package:instapop_/pages/signuppage.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: lightmode,
      debugShowCheckedModeBanner: false,
      initialRoute: '/signup',
      routes: {
        '/login': (context)=> Loginpage(),
        '/signup' : (context)=> SignupPage(),
        '/homepage': (context) => Homepage(),
        '/pagestack': (context)=>PageStack(),
        '/profilesetup': (context)=>ProfileSetupPage()
      },
    );
  }
}
