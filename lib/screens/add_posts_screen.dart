import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_flutter/models/user.dart';
import 'package:instagram_flutter/provider/user_provider.dart';
import 'package:instagram_flutter/resources/firestore_methods.dart';
import 'package:instagram_flutter/utils/colors.dart';
import 'package:instagram_flutter/utils/image_select.dart';
import 'package:instagram_flutter/utils/snack_bar_util.dart';
import 'package:provider/provider.dart';

class AddPostsScreen extends StatefulWidget {
  AddPostsScreen({Key? key}) : super(key: key);

  @override
  _AddPostsScreenState createState() => _AddPostsScreenState();
}

class _AddPostsScreenState extends State<AddPostsScreen> {
  Uint8List? _file;
  final TextEditingController _captionController = TextEditingController();
  bool _isloading = false;

  _selectImage(BuildContext context) async {
    return showDialog(context: context, builder: (context) {
        return SimpleDialog(
          title: const Text("Create a Post"),
          children: [
            SimpleDialogOption(
              padding: const EdgeInsets.all(22),
              child: const Text("Take a photo"),
              onPressed: () async {
                Navigator.of(context).pop();
                Uint8List file = await pickImage(ImageSource.camera);
                setState(() {
                  _file = file;
                });
              },
            ),
            SimpleDialogOption(
              padding: const EdgeInsets.all(22),
              child: const Text("Choose from Gallery"),
              onPressed: () async {
                Navigator.of(context).pop();
                Uint8List file = await pickImage(ImageSource.gallery);
                setState(() {
                  _file = file;
                });
              },
              
            ),
            SimpleDialogOption(
              padding: const EdgeInsets.all(22),
              child: const Text("Cancel"),
              onPressed: () async {
                Navigator.of(context).pop();
              },
              
            ),
          ],
        );
    });
  }

  void clearImage(){
    setState(() {
      _file = null;
      _captionController.clear();
    });
  }

  void postImage(
    String uid,
    String userName,
    String profileImage
  ) async {
    setState(() {
      _isloading = true;
    });
    String res = "Some Error has occured";
    try {
      res = await FireStoreMethods().uploadPost(_captionController.text, _file!, uid, userName, profileImage);
    } catch (err) {
      res = err.toString();
    }
    setState(() {
      _isloading = false;
    });
    clearImage();
    if(res == "success"){
      showSnackBar("Posted !!", context);
    }
    else{
      showSnackBar(res, context);
    }
  }

  @override
  void dispose() { 
    super.dispose();
    _captionController.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final User user = Provider.of<UserProvider>(context).getUser;

    return _file == null 
    ? Center(
      child: IconButton(
        icon: const Icon(Icons.cloud_upload_rounded),
        onPressed: () => _selectImage(context),
      ),
    )
    : Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        leading:  IconButton(
          onPressed: clearImage, 
          icon: Icon(Icons.arrow_back_rounded)
          ),
          title: const Text("Post To"),
          centerTitle: false,
          actions: [
            TextButton(onPressed:() => postImage(
              user.uid,
              user.userName,
              user.photoURL
            ), 
            child: const Text('Post', style: TextStyle(
              color: Colors.blueAccent,
              fontWeight: FontWeight.bold,
              )
            ),
            )
          ],
      ),
      body: _isloading == true
      ? Center(
        child: const CircularProgressIndicator(
          color: Colors.white,
        )
      )
      : Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(user.photoURL),
              ),
              SizedBox(
                width:  (MediaQuery.of(context).size.width) * 0.45,
                child: TextField(
                  controller: _captionController,
                  decoration: const InputDecoration(
                    hintText: "Write a caption....",
                    border: InputBorder.none,
                  ),
                  maxLines: 8,
                ),
              ),
              SizedBox(
                height: 45,
                width: 45,
                child: AspectRatio(
                  aspectRatio: 487/451,
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: MemoryImage(_file!),
                        fit: BoxFit.fill,
                        alignment: FractionalOffset.topCenter,
                        )
                    ),
                  ),
                  ),
              ),
            ],
          )
        ],
      ),
    );
  }
}