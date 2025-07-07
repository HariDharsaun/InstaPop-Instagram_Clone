import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instapop_/models/usermodel.dart';
import 'package:instapop_/pages/profile_setup.dart';

class Userprofilepage extends StatefulWidget {
  const Userprofilepage({super.key});

  @override
  State<Userprofilepage> createState() => _UserprofilepageState();
}

class _UserprofilepageState extends State<Userprofilepage> {
  Future<UserModel?> fetchUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;

    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromMap(doc.data()!);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<UserModel?>(
        future: fetchUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Colors.blue));
          } else if (snapshot.hasError) {
            return Center(child: Text("Something went wrong."));
          } else if (snapshot.hasData && snapshot.data != null) {
            final user = snapshot.data!;
            return ListView(
              padding: EdgeInsets.all(10),
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
                    Spacer(),
                    IconButton(onPressed: () {}, icon: Icon(Icons.menu)),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    CircleAvatar(
                      radius: MediaQuery.of(context).size.width * 0.1,
                      backgroundImage: user.profileImageUrl.isNotEmpty
                          ? NetworkImage(user.profileImageUrl)
                          : null,
                      backgroundColor: Colors.grey.shade300,
                      child: user.profileImageUrl.isEmpty
                          ? Icon(Icons.person, size: MediaQuery.of(context).size.width * 0.15, color: Colors.black38)
                          : null,
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStat("Posts", "0"),
                          _buildStat("Followers", user.followers.length.toString()),
                          _buildStat("Following", user.following.length.toString()),
                        ],
                      ),
                    )
                  ],
                ),
                SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(user.bio),
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/profilesetup');
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                        child: Text("Edit Profile",style: TextStyle(color: Colors.white),),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                        child: Text("+ Create Post",style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Divider(color: Colors.grey),
                SizedBox(height: 10),
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5,
                  ),
                  itemCount: 10, // Replace with post count
                  itemBuilder: (context, index) {
                    return Container(
                      color: Colors.grey[300],
                      alignment: Alignment.center,
                      child: Text("Post ${index + 1}"),
                    );
                  },
                ),
              ],
            );
          } else {
            return Center(child: Text("User not found."));
          }
        },
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12)),
      ],
    );
  }
}
