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
  bool liked = false;
  late final List<String> likes;
  int likeCount = 0;

  @override
  void initState() {
    super.initState();
    fetchUsername();
  }

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
        liked = widget.post.likes.contains(FirebaseAuth.instance.currentUser!.uid);
        likes = widget.post.likes;
        likeCount = widget.post.likes.length;
      });
    }
  }

  Future<String> fetchFirstUser()async {
    final String userid = widget.post.likes.first;
    if(userid.isNotEmpty)
    {
      try{
        final doc = await FirebaseFirestore.instance.collection("users").doc(userid).get();
        final userMap = doc.data();
        if (userMap != null) {
         final user = UserModel.fromMap(userMap);
         return user.username;
        }
      }
      catch(e)
      {
        print("Error fetching first user: $e");
      }
    }
    return '';
  }

  Future<void> toggleLike() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final postref = FirebaseFirestore.instance.collection('posts').doc(widget.post.postid);

    if (liked) {
      await postref.update({
        'likes': FieldValue.arrayRemove([uid])
      });

      setState(() {
        liked = false;
        likeCount--;
      });
    } else {
      await postref.update({
        'likes': FieldValue.arrayUnion([uid])
      });

      setState(() {
        liked = true;
        likeCount++;
      });
    }
  }

  Future<void> deletePost() async {
    try {
      await FirebaseFirestore.instance.collection('posts').doc(widget.post.postid).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post deleted')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete post!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Post"),
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.navigate_before),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User info row
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage:
                        profile_url.isNotEmpty ? NetworkImage(profile_url) : null,
                    child: profile_url.isEmpty
                        ? const Icon(Icons.person, size: 30, color: Colors.black45)
                        : null,
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        username.isEmpty ? "Loading..." : username,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 16),
                          Text(post.location, style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return ListTile(
                            leading: const Icon(Icons.delete, color: Colors.red),
                            title: const Text('Delete Post'),
                            onTap: () async {
                              Navigator.pop(context);
                              await deletePost();
                            },
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.more_vert),
                  ),
                ],
              ),
            ),

            // Image
            AspectRatio(
                aspectRatio: 0.9,
                child: Image.network(post.imageUrl, fit: BoxFit.cover),
              ),

            // Like, comment, share row
            Row(
              children: [
                IconButton(
                  onPressed: toggleLike,
                  icon: liked
                      ? const Icon(Icons.favorite, color: Colors.red)
                      : const Icon(Icons.favorite_border_outlined),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.comment_outlined),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.telegram_outlined),
                ),
              ],
            ),

            // Like count (if > 0)
            if (likeCount > 0)
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: FutureBuilder(
                    future: fetchFirstUser(), 
                    builder: (context,snapshot){
                      final firstUser = snapshot.data ?? '';
                      return Row(
                              children: [
                                Text(
                                '$likeCount likes',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(width: 5,),
                                Text('by ',),
                                // SizedBox(width: 5,),
                                Text(firstUser,style: TextStyle(fontWeight: FontWeight.bold),),
                                SizedBox(width: 5,),
                                Text('and others')
                              ]
                            );
                    }
                  )
                ),

            // Caption row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Text(
                    username.isEmpty ? "Loading..." : username,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(post.caption, overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            ),

            // Date
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Text(
                DateFormat('MMMM d, y').format(post.time.toDate()),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
