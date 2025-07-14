import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instapop_/models/postmodel.dart';
import 'package:instapop_/pages/uploadpage.dart';
import 'package:instapop_/services/cloudinary.dart';
import 'package:photo_manager/photo_manager.dart';

class AddPostPage extends StatefulWidget {
  const AddPostPage({super.key});

  @override
  State<AddPostPage> createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  List<AssetEntity> images = [];
  AssetEntity? selectedImage;
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    loadImages();
  }

  Future<void> loadImages() async {
    final permission = await PhotoManager.requestPermissionExtend();

    if (!permission.isAuth) return;

    final albums = await PhotoManager.getAssetPathList(type: RequestType.image);
    if (albums.isNotEmpty) {
      final recentalbum = albums[0];
      final assets = await recentalbum.getAssetListPaged(page: 0, size: 10);
      setState(() {
        selectedImage = assets.first;
        images = assets;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Add post'),
          actions: [
            TextButton(
              onPressed: () async {
                final file = await selectedImage!.file;
                if (file != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Uploadpage(imagefile: file),
                    ),
                  );
                }
              },
              child: Text('upload'),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              if (selectedImage != null)
                FutureBuilder(
                  future: selectedImage!.file,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Container(
                        height: MediaQuery.of(context).size.height * 0.3,
                        width: double.infinity,
                        child: Image.file(snapshot.data!, fit: BoxFit.contain),
                      );
                    }
                    return Container();
                  },
                ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                alignment: Alignment.centerLeft,
                width: double.infinity,
                child: Text("Recents", style: TextStyle(fontSize: 20)),
              ),
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5,
                ),
                itemCount: images.length,
                itemBuilder: (context, index) {
                  return FutureBuilder(
                    future: images[index].thumbnailDataWithSize(
                      ThumbnailSize(200, 200),
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(color: Colors.blue),
                        );
                      } else if (snapshot.hasData) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedImage = images[index];
                            });
                          },
                          child: Image.memory(snapshot.data!),
                        );
                      }
                      return Center(child: Text("No images found!"));
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
