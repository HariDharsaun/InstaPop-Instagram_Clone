import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instapop_/models/postmodel.dart';
import 'package:instapop_/services/cloudinary.dart';

class Uploadpage extends StatefulWidget {
  File imagefile;

  Uploadpage({super.key, required this.imagefile});

  @override
  State<Uploadpage> createState() => _UploadpageState();
}

class _UploadpageState extends State<Uploadpage> {

  TextEditingController location_controller = TextEditingController();
  TextEditingController caption_Controller = TextEditingController();

  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> uploadPost() async {
    final imageurl = await Cloudinary.uploadToCloudinary(widget.imagefile);

    final uid = _auth.currentUser!.uid;

    PostModel post = PostModel(
      imageUrl: imageurl, 
      caption: caption_Controller.text, 
      location: location_controller.text, 
      uid: uid, 
      likes: [], 
      comments: [], 
      shares: [], 
      time: Timestamp.now()
    );

    try{
      await _firestore.collection('posts').add(
        post.toMap()
      );

      caption_Controller.clear();
      location_controller.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.black,
          content: Text('Image uploaded successfully!')
        )
      );

      Navigator.pop(context);
    }
    catch(e)
    {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.black,
          content: Text('Image uploaded failed!')
        )
      );
    }

  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: (){
              Navigator.pop(context);
            }, 
            icon: Icon(Icons.navigate_before)
          ),
          actions: [
            GestureDetector(
              onTap: (){
                Navigator.pop(context);
              },
              child: Text("Cancel")
            )
          ],
        ),
        body: Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.35,
              child: Image.file(widget.imagefile, fit: BoxFit.contain),
            ),
            SizedBox(height: 20),
            textfield_helper(location_controller,'Location'),
            textfield_helper(caption_Controller, 'Caption'),
            SizedBox(height: 20,),
            ElevatedButton(
              onPressed: uploadPost,
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.blue,),
                foregroundColor: MaterialStateProperty.all(Colors.white)
              ), 
              child: Text("Upload"),
            ),
          ],
        ),
      ),
    );
  }
}

Widget textfield_helper(TextEditingController controller,String hint) {
  return Padding(
    padding: EdgeInsets.all(8),
    child: TextField(
      controller: controller,
      decoration: InputDecoration(
        hint: Text(hint, style: TextStyle(color: Colors.grey.shade500)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(width: 1, color: Colors.grey.shade500),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(width: 1, color: Colors.grey.shade800),
        ),
      ),
    ),
  );
}

