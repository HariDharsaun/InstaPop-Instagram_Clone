import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instapop_/authentication/auth.dart';
import 'package:instapop_/models/postmodel.dart';
import 'package:instapop_/pages/postcard.dart';
import 'package:instapop_/pages/postview.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _fire = FirebaseFirestore.instance;
  final _uid = FirebaseAuth.instance.currentUser!.uid;
  final AuthService service = AuthService();

  Future<List<PostModel>> fetchPosts() async {
    final userDoc = await _fire.collection('users').doc(_uid).get();
    final following = List<String>.from(userDoc.data()?['following'] ?? []);

    final allPostsSnap = await _fire.collection('posts').get();

    List<PostModel> followedPosts = [];
    List<PostModel> otherPosts = [];

    for (var doc in allPostsSnap.docs) {
      final post = PostModel.fromMap(doc.data());
      if (post.uid == _uid || following.contains(post.uid)) {
        followedPosts.add(post);
      } else {
        otherPosts.add(post);
      }
    }

    return [...followedPosts, ...otherPosts];
  }

  Future<void> _refresh() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              width: 55,
              height: 55,
              child: Image.asset('assets/App_Icon/app_icon.png'),
            ),
            Text('InstaPop', style: GoogleFonts.lobster()),
          ],
        ),

        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.favorite_sharp),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<PostModel>>(
          future: fetchPosts(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            final posts = snap.data ?? [];
            if (posts.isEmpty) {
              return Center(child: Text('No posts available.'));
            }
            return ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, i) => PostCard(post: posts[i]),
            );
          },
        ),
      ),
    );
  }
}
