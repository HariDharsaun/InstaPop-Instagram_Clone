import 'package:firebase_auth/firebase_auth.dart';

class AuthService{
  final FirebaseAuth _auth = FirebaseAuth.instance;


 //To create account
  Future<String> signup(String email,String password) async
  {
    try{
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return "success";
    }
    catch(e)
    {
      return e.toString();
    }
  }

  //LogIn
  Future<String> login(String email,String password) async
  {
    try{
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return "success";
    }catch(e)
    {
      return e.toString();
    }
  }

  //logout
  Future<void> logout()async
  {
    await _auth.signOut();
  }
}