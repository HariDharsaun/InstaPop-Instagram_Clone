import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:instapop_/firebase_options.dart';
import 'package:instapop_/modes/modes.dart';
import 'package:instapop_/modes/theme.dart';
import 'package:instapop_/pages/addpost.dart';
import 'package:instapop_/pages/displayfollowers.dart';
import 'package:instapop_/pages/displayfollowing.dart';
import 'package:instapop_/pages/editprofile.dart';
import 'package:instapop_/pages/homepage.dart';
import 'package:instapop_/pages/loginpage.dart';
import 'package:instapop_/pages/messagingpage.dart';
import 'package:instapop_/pages/newpostpage.dart';
import 'package:instapop_/pages/pagestack.dart';
import 'package:instapop_/pages/profile_setup.dart';
import 'package:instapop_/pages/searchpage.dart';
import 'package:instapop_/pages/signuppage.dart';
import 'package:instapop_/pages/splash.dart';
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
    return GetMaterialApp(
      theme: ThemeData.dark(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      initialRoute: 'splash',
      routes: {
        'splash' : (context) => SplashScreen(),
        '/login': (context)=> Loginpage(),
        '/signup' : (context)=> SignupPage(),
        '/pagestack': (context)=>PageStack(),
        '/homepage': (context) => HomePage(),
        '/search': (context)=> SearchPage(),
        '/newpost':(context) => Newpostpage(),
        '/message': (context)=> MessagingPage(),
        '/userprofile':(context)=> Userprofilepage(),
        '/profilesetup': (context)=>ProfileSetupPage(),
        '/displayfollowers': (context) => FollowersListPage(),
        '/displayfollowings': (context)=> FollowingsListPage(),
        '/addpost' : (context)=> AddPostPage(),
        '/editprofile' : (context)=> EditprofilePage(),
      },
    );
  }
}
