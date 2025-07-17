import 'package:flutter/material.dart';

class AddReelsPage extends StatefulWidget {
  const AddReelsPage({super.key});

  @override
  State<AddReelsPage> createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddReelsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text("No reels yet")),
    );
  }
}