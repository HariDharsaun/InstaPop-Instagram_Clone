import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:instapop_/firebase_options.dart';
import 'package:instapop_/modes/modes.dart';
import 'package:instapop_/pages/homepage.dart';
import 'package:instapop_/pages/loginpage.dart';
import 'package:instapop_/pages/newpostpage.dart';
import 'package:instapop_/pages/pagestack.dart';
import 'package:instapop_/pages/profile_setup.dart';
import 'package:instapop_/pages/reelspage.dart';
import 'package:instapop_/pages/searchpage.dart';
import 'package:instapop_/pages/signuppage.dart';
import 'package:instapop_/pages/userprofilepage.dart';

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
      theme: darkmode,
      debugShowCheckedModeBanner: false,
      initialRoute: FirebaseAuth.instance.currentUser != null ? '/pagestack' : '/login',
      routes: {
        '/login': (context)=> Loginpage(),
        '/signup' : (context)=> SignupPage(),
        '/pagestack': (context)=>PageStack(),
        '/homepage': (context) => Homepage(),
        '/search': (context)=> SearchPage(),
        '/newpost':(context) => Newpostpage(),
        '/reels': (context)=> Reelspage(),
        '/userprofile':(context)=> Userprofilepage(),
        '/profilesetup': (context)=>ProfileSetupPage(),
      },
    );
  }
}
