import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:instapop_/components/authbutton.dart';
import 'package:instapop_/components/textfield.dart';
import 'package:instapop_/models/usermodel.dart';
import 'dart:convert';

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

  File? _profileImage;
  UserModel? userinfo;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  void loadUserData() async {
    userinfo = await fetchUserProfile();
    if (userinfo != null) {
      setState(() {
        Username_controller.text = userinfo!.username;
        bio_controller.text = userinfo!.bio;
      });
    }
  }

  Future<UserModel?> fetchUserProfile() async {
    final doc = await _firestore.collection('users').doc(_auth.currentUser!.uid).get();
    if (doc.exists) return UserModel.fromMap(doc.data()!);
    return null;
  }

  Future<void> pickimage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _profileImage = File(picked.path);
      });
    }
  }

  Future<String> uploadToCloudinary(File imageFile) async {
    const cloudName = "dowmhkair";
    const uploadPreset = "Instapop_upload";

    final uri = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final response = await request.send();
    final resStr = await response.stream.bytesToString();
    final data = json.decode(resStr);
    return data['secure_url'];
  }

  Future<void> saveprofile() async {
    final uid = _auth.currentUser!.uid;
    String imageUrl = "";

    if (_profileImage != null) {
      try {
        imageUrl = await uploadToCloudinary(_profileImage!);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Image upload failed")),
        );
        return;
      }
    }

    final updateData = {
      'username' : Username_controller.text,
      'bio': bio_controller.text
    };

    if(imageUrl.isNotEmpty)
    {
      updateData['profileImageUrl'] = imageUrl;
    }

    try {
      await _firestore.collection('users').doc(uid).update(updateData);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile saved!')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save profile')));
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
              Text("Setup your profile", style: GoogleFonts.lobsterTwo(fontSize: 24)),
              SizedBox(height: 30),
              GestureDetector(
                onTap: pickimage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey.shade400,
                  backgroundImage: _profileImage != null ? FileImage(_profileImage!) : (userinfo?.profileImageUrl != null && userinfo!.profileImageUrl.isNotEmpty ? NetworkImage(userinfo!.profileImageUrl): null),
                  child: (_profileImage == null && userinfo?.profileImageUrl == '' )? Icon(Icons.person, size: 60) : null,
                ),
              ),
              SizedBox(height: 20),
              MyTextfield(controller: Username_controller, hinttext: "Username", obscureText: false, showPwd: false),
              SizedBox(height: 15),
              MyTextfield(controller: bio_controller, hinttext: "Bio", obscureText: false, showPwd: false),
              SizedBox(height: 15),
              AuthButton(name: "Save", function: saveprofile),
            ],
          ),
        ),
      ),
    );
  }
}
