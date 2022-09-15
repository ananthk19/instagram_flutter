import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:instagram_flutter/models/post.dart';
import 'package:instagram_flutter/resources/firebase_storage_methods.dart';
import 'package:uuid/uuid.dart';

class FireStoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //upload a post
  Future<String> uploadPost(
    String description,
    Uint8List file,
    String uid,
    String userName,
    String profImage
  ) async {
    String res = "ERROR occured while uploading post";
    try {
      String postURL = await StorageMethods().uploadImageToStorage('posts', file, true);

      String postId = const Uuid().v1();
      Post post  = Post(
        description: description,
        uid: uid,
        userName: userName,
        postId: postId,
        datePublished: DateTime.now(),
        postURL: postURL,
        profImage: profImage,
        likes: []
      );
      _firestore.collection('posts').doc(postId).set(post.toJson());
      
      res = "success";
    } catch (err) {
      res = err.toString();      
    }
    return res;
  }

  Future<void> likePost(String postId, String uid, List likes) async {
    String res = "";
    try {
      if(likes.contains(uid)){
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayRemove([uid]),
        });
      }
      else {
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayUnion([uid]),
        });
      }
      
    } catch (err) {
      res = err.toString();
    }
  }

  Future<String> postComment(
    String postId,
    String text,
    String uid,
    String name,
    String profilePic
    )  async {

      String res = "Some ERROR happened";

      try {
        if(text.isNotEmpty){
          String commentId = const Uuid().v1();
          await _firestore.collection("posts").doc(postId).collection("comments").doc(commentId).set({
            'profile': profilePic,
            'name': name,
            'uid': uid,
            'text': text,
            'commentId': commentId,
            'datePublished': DateTime.now(),
          });
        }
        else{
          res = "text is empty";
        }
      } catch (err) {
        res = err.toString();
      }

      return res;
  }

  //deleting Post

  Future<String> deletePost(String postId) async {
    String res = "Some ERROR has occurred";
    try {
      await _firestore.collection('posts').doc(postId).delete();
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  // Follow User

  Future<String> followUnfollowUser(
    String our_uid,
    String thier_uid
  ) async {

    String res = "Some ERROR has occurred";
    try {
      DocumentSnapshot snap = await _firestore.collection('users').doc(thier_uid).get();
      List thier_followers = (snap.data()! as dynamic)['followers'];
      
      if(thier_followers.contains(our_uid)){
        await _firestore.collection('users').doc(thier_uid).update({
          "followers": FieldValue.arrayRemove([our_uid])
        });
        await _firestore.collection('users').doc(our_uid).update({
          "following": FieldValue.arrayRemove([thier_uid])
        });
      } else {
        await _firestore.collection('users').doc(thier_uid).update({
          "followers": FieldValue.arrayUnion([our_uid])
        });
        await _firestore.collection('users').doc(our_uid).update({
          "following": FieldValue.arrayUnion([thier_uid])
        });
      }
      res = "success";
      
    } catch (e) {
      res = e.toString();
    }

    return res;
  }
}