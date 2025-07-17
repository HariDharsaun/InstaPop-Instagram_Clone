import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instapop_/authentication/auth.dart';
import 'package:instapop_/models/postmodel.dart';
import 'package:instapop_/models/usermodel.dart';
import 'package:instapop_/pages/postview.dart';

class Userprofilepage extends StatefulWidget {
  const Userprofilepage({super.key});

  @override
  State<Userprofilepage> createState() => _UserprofilepageState();
}

class _UserprofilepageState extends State<Userprofilepage> {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  List<PostModel> post_obj = [];
  final AuthService _auth = AuthService();

  Future<Map<String, dynamic>> fetchAllData() async {
    if (uid == null) return {};

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    UserModel? user;
    if (userDoc.exists && userDoc.data() != null) {
      user = UserModel.fromMap(userDoc.data()!);
    }

    final querySnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .where('uid', isEqualTo: uid)
        .get();

    post_obj = querySnapshot.docs.map((doc) => PostModel.fromMap(doc.data())).toList();

    return {'user': user};
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchAllData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.blue));
          } else if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong."));
          } else if (snapshot.hasData && snapshot.data!['user'] != null) {
            final user = snapshot.data!['user'] as UserModel;
            return ListView(
              padding: const EdgeInsets.all(10),
              children: [
                Row(
                  children: [
                    Text(
                      user.username,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: MediaQuery.of(context).size.width * 0.04,
                      ),
                    ),
                    const Spacer(),
                    PopupMenuButton(
                      icon: const Icon(Icons.menu),
                      onSelected: (value) {
                        if (value == 'theme') {
                          //function
                        } else if (value == 'logout') {
                          logout();
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'theme',
                          child: Row(
                                children: [
                                  Icon(Icons.dark_mode),
                                  const SizedBox(width: 5),
                                  Text('Dark Mode'),
                                ],
                              ),
                        ),
                        const PopupMenuItem(
                          value: 'logout',
                          child: Row(
                            children: [
                              Icon(Icons.logout),
                              SizedBox(width: 5),
                              Text('Logout'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    CircleAvatar(
                      radius: MediaQuery.of(context).size.width * 0.1,
                      backgroundImage: user.profileImageUrl.isNotEmpty
                          ? NetworkImage(user.profileImageUrl)
                          : null,
                      backgroundColor: Colors.grey.shade300,
                      child: user.profileImageUrl.isEmpty
                          ? Icon(Icons.person,
                              size: MediaQuery.of(context).size.width * 0.15,
                              color: Colors.black38)
                          : null,
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStat("Posts", post_obj.length.toString(), () {}),
                          _buildStat("Followers", user.followers.length.toString(),
                              () => Navigator.pushNamed(context, '/displayfollowers')),
                          _buildStat("Following", user.following.length.toString(),
                              () => Navigator.pushNamed(context, '/displayfollowings')),
                        ],
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(user.bio),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          await Navigator.pushNamed(context, '/editprofile');
                          setState(() {});
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                        child: const Text("Edit Profile", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Add post
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                        child: const Text("+ Create Post", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                const Divider(color: Colors.grey),
                const SizedBox(height: 5),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 1,
                    mainAxisSpacing: 1,
                  ),
                  itemCount: post_obj.length,
                  itemBuilder: (context, index) {
                    final post = post_obj[index];
                    return GestureDetector(
                      onTap: () async {
                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PostviewPage(post: post)));
                         if (mounted) setState(() {});
                      },
                      child: Container(
                        color: Colors.grey[300],
                        alignment: Alignment.center,
                        child: Image.network(post.imageUrl, fit: BoxFit.cover),
                      ),
                    );
                  },
                ),
              ],
            );
          } else {
            return const Center(child: Text("User not found."));
          }
        },
      ),
    );
  }

  Widget _buildStat(String label, String value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  void logout() {
    Get.defaultDialog(
      title: "Logout",
      content: const Text('Are you sure you want to logout?'),
      confirm: ElevatedButton(
        onPressed: () {
          Get.back();
          _auth.logout();
          Get.offAllNamed('/login');
        },
        child: const Text("Yes"),
      ),
      cancel: TextButton(
        onPressed: () {
          Get.back();
        },
        child: const Text("Cancel"),
      ),
    );
  }
}
