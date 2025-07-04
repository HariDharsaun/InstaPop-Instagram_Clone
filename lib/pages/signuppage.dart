import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instapop_/authentication/auth.dart';
import 'package:instapop_/components/authbutton.dart';
import 'package:instapop_/components/textfield.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  TextEditingController email_controller = TextEditingController();
  TextEditingController Username_controller= TextEditingController();
  TextEditingController pwd_controller = TextEditingController();
  TextEditingController cnfpwd_controller = TextEditingController();

  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    //credentail check
    int pwdcheck(String pwd, String cnfpwd) {
      if (pwd.length < 8) {
        return 1;
      } else if (pwd != cnfpwd) {
        return 2;
      }
      return 3;
    }

    void callbackfunc() async {
      if (pwdcheck(pwd_controller.text, cnfpwd_controller.text) == 3) {
        final msg = await _authService.signup(
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
      } else if (pwdcheck(pwd_controller.text, cnfpwd_controller.text) == 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.red.shade500, content: Text("password must be atleast 8 characters")),
        );
      } else if (pwdcheck(pwd_controller.text, cnfpwd_controller.text) == 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.red.shade500,content: Text("password & confirm password are not same")),
        );
      }
    }

    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Create an account",
                style: GoogleFonts.lobsterTwo(
                  fontSize: MediaQuery.of(context).size.width * 0.08,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 50),
              MyTextfield(
                controller: email_controller,
                hinttext: "Email",
                obscureText: false,
                showPwd: false,
              ),
              SizedBox(height: 15),
              MyTextfield(
                controller: Username_controller,
                hinttext: "Username",
                obscureText: false,
                showPwd: false,
              ),
              SizedBox(height: 15),
              MyTextfield(
                controller: pwd_controller,
                hinttext: "Password",
                obscureText: true,
                showPwd: true,
              ),
              SizedBox(height: 15),
              MyTextfield(
                controller: cnfpwd_controller,
                hinttext: "Confirm Password",
                obscureText: true,
                showPwd: true,
              ),
              SizedBox(height: 15),
              AuthButton(name: "Sign Up",function: callbackfunc,),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: Divider(thickness: 1)),
                  SizedBox(width: 10),
                  Text("Or"),
                  SizedBox(width: 10),
                  Expanded(child: Divider(thickness: 1)),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account?"),
                  SizedBox(width: 10),
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    child: Text(
                      "Log In",
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
