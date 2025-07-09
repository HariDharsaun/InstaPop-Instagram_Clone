import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:instapop_/components/textfield.dart';
import 'package:instapop_/models/usermodel.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController search_controller = TextEditingController();

  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Set<String> followingUserids = {};

  @override
  void initState()
  {
    super.initState();
    fetchFollowingList();
  }

  void fetchFollowingList() async {
  final uid = _auth.currentUser!.uid;
  final doc = await _firestore.collection('users').doc(uid).get();
  if (doc.exists && doc.data()!.containsKey('following')) {
    List<dynamic> followingList = doc['following'];
    if (!mounted) return;
    setState(() {
      followingUserids = Set<String>.from(followingList);
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              searchbar(),
              SizedBox(height: 10,),
              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .snapshots(),
                builder: (context, snapshots) {
                  if (snapshots.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator(color: Colors.blue));
                  } else if (snapshots.hasData &&
                      snapshots.data!.docs != null) {
                    List<UserModel> users = snapshots.data!.docs
                        .map((doc) {
                          return UserModel.fromMap(doc.data());
                        })
                        .where((user) => user.email != _auth.currentUser!.email)
                        .toList();

                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final targetUserid = snapshots.data!.docs[index].id;
                        bool isFollowing = followingUserids.contains(targetUserid);
                        return ListTile(
                          splashColor: Colors.blue,
                          title: Text(users[index].username),
                          subtitle: Text(
                            users[index].bio,
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12
                            ),
                          ),
                          trailing: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isFollowing ?  Colors.red.shade400 : Colors.blue, 
                            ),
                            onPressed: () async {
                              final currentUserUid = _auth.currentUser!.uid;
                              final currentUserDoc = await _firestore.collection('users').doc(currentUserUid).get();

                              //follow
                              if(!followingUserids.contains(targetUserid))
                              {
                                setState(() {
                                  followingUserids.add(targetUserid);
                                });

                                //Add following to the currentuser following list
                                await _firestore.collection('users').doc(currentUserUid).update(
                                  {
                                    'following' : FieldValue.arrayUnion([targetUserid])
                                  }
                                );

                                //add followers to the targetuser folllowers list
                                await _firestore.collection('users').doc(targetUserid).update(
                                  {
                                    'followers' : FieldValue.arrayUnion([currentUserUid])
                                  }
                                );
                              }
                              //unfollow
                              else
                              {
                                
                                setState(() {
                                  followingUserids.remove(targetUserid);
                                });

                                 await _firestore.collection('users').doc(currentUserUid).update(
                                  {
                                    'following' : FieldValue.arrayRemove([targetUserid])
                                  }
                                );

                                 await _firestore.collection('users').doc(targetUserid).update(
                                  {
                                    'followers' : FieldValue.arrayRemove([currentUserUid])
                                  }
                                );

                              }
                            },
                            child: (isFollowing)
                                ? Text(
                                    "un follow",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  )
                                : Text(
                                    "follow",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                          ),
                        );
                      },
                    );
                  } else if (snapshots.hasError) {
                    return Center(child: Text("Something went wrong"));
                  } else {
                    return Center(child: Text("No user found"));
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget searchbar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(50),
        border: BoxBorder.all(width: 0.3),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(width: 15),
          Icon(Icons.search, color: Colors.grey.shade600),
          Expanded(
            child: TextField(
              controller: search_controller,
              style: TextStyle(color: Colors.black),
              cursorColor: Colors.blue,
              decoration: InputDecoration(
                // fillColor: Colors.grey.shade200,
                // filled: true,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(10),
                ),
                hintText: "search",
                hintStyle: TextStyle(color: Colors.grey.shade600),
              ),
              obscureText: false,
            ),
          ),
        ],
      ),
    );
  }
}
