import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instapop_/pages/uploadpage.dart';
import 'package:photo_manager/photo_manager.dart';

class AddPostPage extends StatefulWidget {
  const AddPostPage({super.key});

  @override
  State<AddPostPage> createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  List<AssetEntity> images = [];
  AssetEntity? selectedImage;
  bool loading = true;

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
      final recentAlbum = albums[0];
      final assets = await recentAlbum.getAssetListPaged(page: 0, size: 50);
      setState(() {
        images = assets;
        selectedImage = assets.isNotEmpty ? assets.first : null;
        loading = false;
      });
    } else {
      setState(() {
        images = [];
        selectedImage = null;
        loading = false;
      });
    }
  }

  void navigateToUpload(File file) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => Uploadpage(imagefile: file),
        transitionsBuilder: (_, anim, __, child) {
          return SlideTransition(
            position: Tween(begin: const Offset(1, 0), end: Offset.zero).animate(anim),
            child: child,
          );
        },
      ),
    );
  }

  Future<void> pickFromGallery() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      navigateToUpload(File(picked.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Post", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: ElevatedButton(
              onPressed: () async {
                final file = await selectedImage?.file;
                if (file != null) {
                  navigateToUpload(file);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text("Next"),
            ),
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : images.isEmpty
              ? const Center(child: Text("No images found"))
              : Column(
                  children: [
                    if (selectedImage != null)
                      FutureBuilder<File?>(
                        future: selectedImage!.file,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Container(
                              height: MediaQuery.of(context).size.height * 0.35,
                              width: double.infinity,
                              child: Image.file(snapshot.data!, fit: BoxFit.cover),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Recents", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                      ),
                    ),
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 3,
                          crossAxisSpacing: 3,
                        ),
                        itemCount: images.length,
                        itemBuilder: (context, index) {
                          final isSelected = selectedImage == images[index];
                          return FutureBuilder<Uint8List?>(
                            future: images[index].thumbnailDataWithSize(const ThumbnailSize(200, 200)),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedImage = images[index];
                                    });
                                  },
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                        child: Image.memory(snapshot.data!, fit: BoxFit.cover),
                                      ),
                                      if (isSelected)
                                        Container(
                                          color: Colors.black.withOpacity(0.4),
                                          child: const Center(
                                            child: Icon(Icons.check_circle, color: Colors.white, size: 30),
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              }
                              return const Center(child: CircularProgressIndicator());
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton.extended(
        foregroundColor: Colors.white,
        onPressed: pickFromGallery,
        icon: const Icon(Icons.photo_library),
        label: const Text("Gallery"),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
