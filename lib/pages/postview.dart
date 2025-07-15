import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instapop_/models/postmodel.dart';
import 'package:instapop_/models/usermodel.dart';
import 'package:intl/intl.dart';

class PostviewPage extends StatefulWidget {
  final PostModel post;

  const PostviewPage({super.key, required this.post});

  @override
  State<PostviewPage> createState() => _PostviewPageState();
}

class _PostviewPageState extends State<PostviewPage> {
  String username = '';
  String profile_url = '';

  Future<void> fetchUsername() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    if (doc.exists) {
      final user = UserModel.fromMap(doc.data()!);
      setState(() {
        username = user.username;
        profile_url = user.profileImageUrl;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUsername();
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Post"),
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.navigate_before),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: profile_url.isNotEmpty
                        ? NetworkImage(profile_url)
                        : null,
                    child: profile_url.isEmpty
                        ? Icon(Icons.person, size: 30, color: Colors.black45)
                        : null,
                  ),
                  SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        username.isEmpty ? "Loading..." : username,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 16),
                          Text(post.location, style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                  Spacer(),
                  IconButton(onPressed: () {}, icon: Icon(Icons.more_vert)),
                ],
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.35,
              width: double.infinity,
              child: Image.network(post.imageUrl, fit: BoxFit.contain),
            ),
            Row(
              children: [
                IconButton(onPressed: () {}, icon: Icon(Icons.favorite_border)),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.comment_outlined),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.telegram_outlined),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Text(
                    username.isEmpty ? "Username" : username,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 5),
                  Expanded(
                    child: Text(post.caption, overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Text(
                DateFormat('MMMM d, y').format(post.time.toDate()),
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
