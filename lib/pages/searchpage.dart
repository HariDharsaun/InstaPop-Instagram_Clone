import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instapop_/models/usermodel.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Set<String> followingUserIds = {};
  String searchText = '';

  @override
  void initState() {
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
        followingUserIds = Set<String>.from(followingList);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              buildSearchBar(),
              const SizedBox(height: 10),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore.collection('users').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return const Center(child: Text("Something went wrong"));
                    }

                    final users = snapshot.data!.docs
                        .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
                        .where((user) =>
                            user.email != _auth.currentUser!.email &&
                            user.username.toLowerCase().contains(searchText.toLowerCase()))
                        .toList();

                    if (users.isEmpty) {
                      return const Center(child: Text("No user found"));
                    }

                    return ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        final userId = snapshot.data!.docs[index].id;
                        final isFollowing = followingUserIds.contains(userId);

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.grey.shade300,
                            backgroundImage: user.profileImageUrl.isNotEmpty
                                ? NetworkImage(user.profileImageUrl)
                                : null,
                            child: user.profileImageUrl.isEmpty
                                ? const Icon(Icons.person, color: Colors.black38)
                                : null,
                          ),
                          title: Text(user.username),
                          subtitle: Text(
                            user.bio,
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                          ),
                          trailing: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isFollowing ? Colors.red : Colors.blue,
                            ),
                            onPressed: () => toggleFollow(userId, isFollowing),
                            child: Text(
                              isFollowing ? 'Unfollow' : 'Follow',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSearchBar() {
    return TextField(
      controller: searchController,
      onChanged: (value) {
        setState(() {
          searchText = value;
        });
      },
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search),
        hintText: 'Search username...',
        filled: true,
        fillColor: Colors.grey.shade200,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
      ),
    );
  }

  void toggleFollow(String targetUserId, bool isCurrentlyFollowing) async {
    final currentUserUid = _auth.currentUser!.uid;

    if (isCurrentlyFollowing) {
      setState(() => followingUserIds.remove(targetUserId));
      await _firestore.collection('users').doc(currentUserUid).update({
        'following': FieldValue.arrayRemove([targetUserId])
      });
      await _firestore.collection('users').doc(targetUserId).update({
        'followers': FieldValue.arrayRemove([currentUserUid])
      });
    } else {
      setState(() => followingUserIds.add(targetUserId));
      await _firestore.collection('users').doc(currentUserUid).update({
        'following': FieldValue.arrayUnion([targetUserId])
      });
      await _firestore.collection('users').doc(targetUserId).update({
        'followers': FieldValue.arrayUnion([currentUserUid])
      });
    }
  }
}
