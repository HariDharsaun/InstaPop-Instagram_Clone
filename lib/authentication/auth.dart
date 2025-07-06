import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instapop_/models/usermodel.dart';

class AuthService{
  final FirebaseAuth _auth = FirebaseAuth.instance;

 //To create account
  Future<String> signup(String email,String username ,String password) async
  {
    try{
      UserCredential cred =  await _auth.createUserWithEmailAndPassword(email: email, password: password);
      UserModel user = UserModel(
        email: email, 
        username: username, 
        bio: '', 
        profileImageUrl: '', 
        followers: [], 
        following: [], 
        timeStamp: Timestamp.now().toDate().toString()
      );

      await FirebaseFirestore.instance.collection('users').doc(cred.user!.uid).set(user.toMap());
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