class UserModel{
  final String email;
  final String username;
  final String bio;
  final String profileImageUrl;
  final List<String> followers;
  final  List<String> following;
  final String timeStamp;

  UserModel(
    {
      required this.email,
      required this.username,
      required this.bio,
      required this.profileImageUrl,
      required this.followers,
      required this.following,
      required this.timeStamp
    }
  );

  Map<String,dynamic> toMap()
  {
    return{
      'email' : email,
      'username': username,
      'bio':bio,
      'profileImageUrl': profileImageUrl,
      'followers': followers,
      'following': following,
      'timestamp': timeStamp
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      email: map['email'] ?? '',
      username: map['username'] ?? '',
      bio: map['bio'] ?? '',
      profileImageUrl: map['profileImageUrl'] ?? '',
      followers: List<String>.from(map['followers'] ?? []),
      following: List<String>.from(map['following'] ?? []),
      timeStamp: map['timestamp']?.toDate().toString() ?? '',
    );
  }
}