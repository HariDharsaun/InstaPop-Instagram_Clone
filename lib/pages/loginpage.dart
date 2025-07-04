import 'package:flutter/material.dart';
import 'package:instapop_/authentication/auth.dart';
import 'package:instapop_/components/authbutton.dart';
import 'package:instapop_/components/textfield.dart';
import 'package:google_fonts/google_fonts.dart';

class Loginpage extends StatefulWidget {
  const Loginpage({super.key});

  @override
  State<Loginpage> createState() => _LoginpageState();
}

class _LoginpageState extends State<Loginpage> {

  TextEditingController email_controller = TextEditingController();
  TextEditingController pwd_controller = TextEditingController();

  final AuthService _authService = AuthService();

  void callbackfunc() async
  {
    final msg = await _authService.login(
          email_controller.text,
          pwd_controller.text,
        );
        if (msg == "success") {
          Navigator.pushNamed(context, '/homepage');
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(backgroundColor: Colors.red.shade500,content: Text(msg)));
        }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: Padding(
          padding: EdgeInsetsGeometry.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("InstaPop",style: GoogleFonts.lobsterTwo(fontSize: MediaQuery.of(context).size.width*0.1,fontWeight: FontWeight.bold)),
              SizedBox(height: 50),
              MyTextfield(controller: email_controller,hinttext: "Email",obscureText:false,showPwd: false,),
              SizedBox(height: 15,),
              MyTextfield(controller: pwd_controller,hinttext: "Password",obscureText:true,showPwd: true,),
              SizedBox(height: 15,),
              Container(
                alignment: Alignment.bottomRight,
                child: InkWell(
                  onTap: (){},
                  child: Text("Forgot password?",style: TextStyle(color: Colors.blue,fontWeight: FontWeight.bold),)
                ),
              ),
              SizedBox(height: 15,),
              AuthButton(name: "Log In",function: callbackfunc,),
              SizedBox(height: 20,),
              Row(
                children: [
                  Expanded(child: Divider(thickness: 1,)),
                  SizedBox(width: 10,),
                  Text("Or"),
                  SizedBox(width: 10,),
                  Expanded(child: Divider(thickness: 1,))
               ]
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account?"),
                  SizedBox(width: 10),
                  InkWell(
                    onTap: (){
                      Navigator.pushNamed(context, '/signup');
                    },
                    child: Text("Sign Up",style: TextStyle(color: Colors.blue,fontWeight: FontWeight.bold),)
                  )
                ]
              )
            ],
          ),
        ),
      ),
    );
  }
}