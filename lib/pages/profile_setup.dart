import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instapop_/components/authbutton.dart';
import 'package:instapop_/components/textfield.dart';

class ProfileSetupPage extends StatefulWidget {
  const ProfileSetupPage({super.key});

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  TextEditingController Username_controller = TextEditingController();
  TextEditingController bio_controller = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _firestorage = FirebaseStorage.instance;

  File? _profileImage;

  //pick image
  Future<void> pickimage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _profileImage = File(picked.path);
      });
    }
  }

  Future<void> saveprofile() async {
    final uid = _auth.currentUser!.uid;
    if (uid == null) return;

    String imageurl = "";

    if (_profileImage != null) {
      try {
        final ref = _firestorage.ref().child("profileImages/$uid.jpg");

        // Upload the file and wait for completion
        UploadTask uploadTask = ref.putFile(_profileImage!);
        TaskSnapshot snapshot = await uploadTask;

        // Get download URL after successful upload
        imageurl = await snapshot.ref.getDownloadURL();
      } catch (e) {
        print("UPLOAD ERROR: $e");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(backgroundColor: Colors.red.shade500,content: Text("Image upload failed")));
        return;
      }
    }

    //store in firestore
    try {
      await _firestore.collection('users').doc(uid).update({
        'username': Username_controller.text.trim(),
        'bio': bio_controller.text.trim(),
        'profileImageUrl': imageurl,
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Profile saved!')));

      Navigator.pushReplacementNamed(context, '/homepage');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save prfile')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Setup your profile",
                    style: GoogleFonts.lobsterTwo(
                      fontWeight: FontWeight.w600,
                      fontSize: MediaQuery.of(context).size.width * 0.06,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 40),
              GestureDetector(
                onTap: pickimage,
                child: CircleAvatar(
                  radius: MediaQuery.of(context).size.width * 0.125,
                  backgroundColor: Colors.grey.shade400,
                  backgroundImage: _profileImage != null
                      ? FileImage(_profileImage!)
                      : null,
                  child: _profileImage == null
                      ? Icon(
                          Icons.person,
                          size: MediaQuery.of(context).size.width * 0.15,
                          color: Colors.grey.shade700,
                        )
                      : null,
                ),
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
                controller: bio_controller,
                hinttext: "Bio",
                obscureText: false,
                showPwd: false,
              ),
              SizedBox(height: 15),
              AuthButton(name: "save", function: saveprofile),
            ],
          ),
        ),
      ),
    );
  }
}
