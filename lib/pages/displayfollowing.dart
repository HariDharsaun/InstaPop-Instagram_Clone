import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instapop_/models/usermodel.dart';

class FollowingsListPage extends StatefulWidget {
  const FollowingsListPage({super.key});

  @override
  State<FollowingsListPage> createState() => _FollowingsListPageState();
}

class _FollowingsListPageState extends State<FollowingsListPage> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchFollowingsData() async {
    final doc = await _fireStore.collection('users').doc(_auth.currentUser!.uid).get();
    if (doc.exists && doc.data()!.containsKey('following')) {
      List<String> followingIds = List<String>.from(doc['following']);

      return await Future.wait(followingIds.map((id) async {
        final userDoc = await _fireStore.collection('users').doc(id).get();
        return {'uid': id, 'data': UserModel.fromMap(userDoc.data()!)};
      }));
    }
    return [];
  }

  Future<void> unfollowUser(String targetUserId) async {
    final currentUserUid = _auth.currentUser!.uid;

    await _fireStore.collection('users').doc(currentUserUid).update({
      'following': FieldValue.arrayRemove([targetUserId])
    });

    await _fireStore.collection('users').doc(targetUserId).update({
      'followers': FieldValue.arrayRemove([currentUserUid])
    });

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Followings", style: TextStyle(fontWeight: FontWeight.w500)),
        ),
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: fetchFollowingsData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.blue));
            } else if (snapshot.hasError) {
              return const Center(child: Text("Something went wrong"));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("No followings"));
            }

            final followings = snapshot.data!;

            return ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              itemCount: followings.length,
              separatorBuilder: (_, __) => Divider(height: 1),
              itemBuilder: (context, index) {
                final userModel = followings[index]['data'] as UserModel;
                final uid = followings[index]['uid'] as String;

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  leading: CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: userModel.profileImageUrl.isNotEmpty
                        ? NetworkImage(userModel.profileImageUrl)
                        : null,
                    child: userModel.profileImageUrl.isEmpty
                        ? const Icon(Icons.person, color: Colors.black38)
                        : null,
                  ),
                  title: Text(
                    userModel.username,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    userModel.bio,
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                  trailing: ElevatedButton(
                    onPressed: () async {
                      await unfollowUser(uid);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade400,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text("Un follow", style: TextStyle(color: Colors.white)),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
