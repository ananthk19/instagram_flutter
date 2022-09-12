
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';

class Post {
  final String description;
  final String uid;
  final String userName;
  final String postId;
  final DateTime datePublished;
  final String profImage;
  final String postURL;
  final likes;

  const Post({
    required this.description,
    required this.uid,
    required this.postId,
    required this.userName,
    required this.profImage,
    required this.postURL,
    required this.likes,
    required this.datePublished
  });

  Map<String, dynamic> toJson() => {
    "description": description,
    "uid": uid,
    "postURL": postURL,
    "profImage": profImage,
    "datePublished": datePublished,
    "likes": likes,
    "username": userName,
    "postId": postId

  };

  static Post fromSnap(DocumentSnapshot snap) {
    Map<String, dynamic> data = snap.data() as Map<String, dynamic>;
    return Post(
      uid: data['uid'],
      postURL: data['postURL'],
      description: data['description'],
      profImage: data['profImage'],
      datePublished: data['datePublished'],
      likes: data['likes'],
      userName: data['username'],
      postId: data['postId']
    );
  }

}