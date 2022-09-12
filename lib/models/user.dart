
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';

class User {
  final String email;
  final String uid;
  final String userName;
  final String bio;
  final List followers;
  final List following;
  final String photoURL;

  const User({
    required this.email,
    required this.uid,
    required this.bio,
    required this.userName,
    required this.photoURL,
    required this.followers,
    required this.following,
  });

  Map<String, dynamic> toJson() => {
    "username": userName,
    "uid": uid,
    "email": email,
    "bio": bio,
    "followers": followers,
    "following": following,
    "photoURL": photoURL
  };

  static User fromSnap(DocumentSnapshot snap) {
    Map<String, dynamic> data = snap.data() as Map<String, dynamic>;
    return User(
      uid: data['uid'],
      email: data['email'],
      userName: data['username'],
      bio: data['bio'],
      followers: data['followers'],
      following: data['following'],
      photoURL: data['photoURL'],
    );
  }

}