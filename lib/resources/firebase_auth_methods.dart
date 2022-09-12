import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram_flutter/resources/firebase_storage_methods.dart';
import 'package:instagram_flutter/models/user.dart' as model;

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
 
  Future<model.User> getUserDetails() async {
    User currentUser = _auth.currentUser!;

    DocumentSnapshot snap = await _firestore.collection('users').doc(currentUser.uid).get();
    
    Map<String, dynamic> data = snap.data() as Map<String, dynamic>;
    return model.User.fromSnap(snap);

  }

  //signUp User
  Future<String> signUpUser({
    required String email,
    required String password,
    required String userName,
    required String bio,
    required Uint8List file
  }) async{
    String res = "Some error in SignUp";
    // print("The values are $email, $password, $userName, $bio");
    try{
      if(email.isNotEmpty && password.isNotEmpty && userName.isNotEmpty && bio.isNotEmpty && file.isNotEmpty){
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
          email: email, 
          password: password
          );
        
        String photoURL = await StorageMethods().uploadImageToStorage('profilePics', file, false);
        // add user to database

        model.User user = model.User(
          email: email,
          userName: userName,
          uid: cred.user!.uid,
          bio: bio,
          photoURL: photoURL,
          followers: [],
          following: [],
        );
        await _firestore.collection('users').doc(cred.user!.uid).set(user.toJson());

        // await _firestore.collection('users').add({
        //   'username': userName,
        //   'uid': cred.user!.uid,
        //   'email': email,
        //   'bio': bio,
        //   'followers': [],
        //   'following': []
        // });
        res = "success";
      }
    }
    catch(err){
      res = err.toString();
    }
    return res;
  }

  //Login As A User
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {

    String res = "Some error has occured";

    try {
      if(email.isNotEmpty && password.isNotEmpty){
        UserCredential cred = await _auth.signInWithEmailAndPassword(
          email: email, 
          password: password
          );
        res = "success";
      }
      
    } catch (err) {
      res = err.toString();
    }

    return res;
  }
}