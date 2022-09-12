import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class StorageMethods {
  final FirebaseStorage storage = FirebaseStorage.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  // adding imageto firebase storage

  Future<String> uploadImageToStorage(
    String childName,
    Uint8List file, 
    bool isPost) async {
      String id = "";

      if(isPost){
        id = const Uuid().v1();
      }
      else{
        id = auth.currentUser!.uid;
      }
      // print("Inside uploadtoStrorage");
      Reference ref = storage.ref().child(childName).child(id);

      UploadTask uploadTask = ref.putData(file);
      TaskSnapshot snap = await uploadTask;
      String downloadURL = await snap.ref.getDownloadURL();
      return downloadURL;
    }
}