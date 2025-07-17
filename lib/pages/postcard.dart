import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:instapop_/models/postmodel.dart';
import 'package:instapop_/models/usermodel.dart';

class PostCard extends StatefulWidget {
  final PostModel post;

  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late bool liked;
  late int likeCount;

  @override
  void initState() {
    super.initState();
    liked = widget.post.likes.contains(FirebaseAuth.instance.currentUser!.uid);
    likeCount = widget.post.likes.length;
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
    final postRef = FirebaseFirestore.instance.collection('posts').doc(widget.post.postid);

    if (liked) {
      await postRef.update({
        'likes': FieldValue.arrayRemove([uid])
      });
      setState(() {
        liked = false;
        likeCount--;
      });
    } else {
      await postRef.update({
        'likes': FieldValue.arrayUnion([uid])
      });
      setState(() {
        liked = true;
        likeCount++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(widget.post.uid).get(),
      builder: (context, snap) {
        if (!snap.hasData) return SizedBox.shrink();

        final user = UserModel.fromMap(snap.data!.data() as Map<String, dynamic>);
        final post = widget.post;

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          padding: const EdgeInsets.only(bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Info
              ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(user.profileImageUrl),
                ),
                title: Text(user.username),
                subtitle: Row(
                  children: [
                    const Icon(Icons.location_on, size: 16),
                    Text(post.location, style: const TextStyle(fontSize: 12)),
                  ],
                ),
                trailing: Icon(Icons.more_vert),
              ),

              // Post Image
              AspectRatio(
                aspectRatio: 0.8,
                child: Image.network(post.imageUrl, fit: BoxFit.cover),
              ),

              // Action Icons
              Row(
                children: [
                  IconButton(
                    onPressed: toggleLike,
                    icon: Icon(
                      liked ? Icons.favorite : Icons.favorite_border,
                      color: liked ? Colors.red : null,
                    ),
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

              // Like Count
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

              // Caption
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Text(
                      user.username,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 4),
                    Expanded(child: Text(post.caption)),
                  ],
                ),
              ),

              // Post Date
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                child: Text(
                  DateFormat('MMMM d, y').format(post.time.toDate()),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
