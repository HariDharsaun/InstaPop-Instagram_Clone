import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkConnectivityAndNavigate();
  }

  Future<void> checkConnectivityAndNavigate() async {
    var connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No internet connection'),
          duration: Duration(seconds: 3),
        ),
      );
      await Future.delayed(const Duration(seconds: 3));
      checkConnectivityAndNavigate();
    } else {
      await Future.delayed(const Duration(seconds: 2));
      if (FirebaseAuth.instance.currentUser != null) {
        Navigator.pushReplacementNamed(context, '/pagestack');
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/App_Icon/app_icon.png',
          width: MediaQuery.of(context).size.width * 0.4,
        ),
      ),
    );
  }
}
