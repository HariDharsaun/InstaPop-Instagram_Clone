import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String imageUrl;
  final String caption;
  final String location;
  final String uid;
  final List<String> likes;
  final List<String> comments;
  final List<String> shares;
  final Timestamp time;

  PostModel({
    required this.imageUrl,
    required this.caption,
    required this.location,
    required this.uid,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.time,
  });

  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      imageUrl: map['imageUrl'] ?? '',
      caption: map['caption'] ?? '',
      location: map['location'] ?? '',
      uid: map['uid'] ?? '',
      likes: List<String>.from(map['likes'] ?? []),
      comments: List<String>.from(map['comments'] ?? []),
      shares: List<String>.from(map['shares'] ?? []),
      time: map['time'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'imageUrl': imageUrl,
      'caption': caption,
      'location': location,
      'uid': uid,
      'likes': likes,
      'comments': comments,
      'shares': shares,
      'time': time,
    };
  }
}
