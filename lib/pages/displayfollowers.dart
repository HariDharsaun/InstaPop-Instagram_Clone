import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instapop_/models/usermodel.dart';

class FollowersListPage extends StatefulWidget {
  const FollowersListPage({super.key});

  @override
  State<FollowersListPage> createState() => _FollowersListPageState();
}

class _FollowersListPageState extends State<FollowersListPage> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  List<String> followersid = [];

  Future<List<UserModel>> fetchFollowersData() async {
    final doc = await _fireStore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .get();
    if (doc.exists && doc.data()!.containsKey('followers')) {
      List<String> followerIds = List<String>.from(doc['followers']);

      List<UserModel> followers = await Future.wait(
        followerIds.map((id) async {
          final userDoc = await _fireStore.collection('users').doc(id).get();
          return UserModel.fromMap(userDoc.data()!);
        }),
      );

      return followers;
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Followers",style: TextStyle(fontWeight: FontWeight.w400),),
        ),
        body: FutureBuilder(
          future: fetchFollowersData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: Colors.blue),
              );
            }
            else if (snapshot.hasError) {
              return Center(child: Text("Something went wrong"));
            } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              final users = snapshot.data;
              return ListView.builder(
                shrinkWrap: true,
                itemCount: users!.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(users[index].username),
                    subtitle: Text(users[index].bio,style: TextStyle(color: Colors.grey.shade400,fontSize: 12),),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white
                      ),
                      onPressed: () async {
                        final currentUserUid = _auth.currentUser!.uid;
                        final email = users[index].email;

                        // Find the document with matching email
                        final query = await _fireStore
                            .collection('users')
                            .where('email', isEqualTo: email)
                            .get();

                        if (query.docs.isNotEmpty) {
                          final targetUserId = query.docs.first.id;

                          // Remove target user from current user's followers
                          await _fireStore.collection('users').doc(currentUserUid).update({
                            'followers': FieldValue.arrayRemove([targetUserId])
                          });

                          // Remove current user from target user's following
                          await _fireStore.collection('users').doc(targetUserId).update({
                            'following': FieldValue.arrayRemove([currentUserUid])
                          });

                          setState(() {
                            users.remove(users[index]);
                          }); // Refresh the UI
                      }
                      },
                      child: Text('follow')
                    ),
                  );
                },
              );
            } else {
              return Center(child: Text('No followers'));
            }
          },
        ),
      ),
    );
  }
}

extension on QuerySnapshot<Map<String, dynamic>> {
  operator [](String other) {}
}
