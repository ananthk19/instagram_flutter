import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_flutter/main.dart';
import 'package:instagram_flutter/resources/firestore_methods.dart';
import 'package:instagram_flutter/screens/login_screen.dart';
import 'package:instagram_flutter/utils/colors.dart';
import 'package:instagram_flutter/utils/snack_bar_util.dart';
import 'package:instagram_flutter/widgets/follow_button.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;
  ProfileScreen({
    Key? key,
    required this.uid,
  }) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var userData = {};
  // var postDatas = {};
  var postLen = 0;
  bool isFollowing = false;
  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  void followUnfollow() async {
    // print("at followUnfollow");
    setState(() {
      isLoading = true;
    });

    if(isFollowing == true){
      setState(() {
        isFollowing = false;
      });
    }
    else{
      setState(() {
        isFollowing = true;
      });
    }
    String res = await FireStoreMethods().followUnfollowUser(
      FirebaseAuth.instance.currentUser!.uid, 
      widget.uid,
      );
    if(res != "success"){
      showSnackBar(res, context);
    }

    setState(() {
      isLoading = false;
    });

    // setState(() {
    //   isFollowing == true ? false : true;
    // });
  }

  void signOut() async {
    setState(() {
      isLoading = true;
    });
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => MyApp()
        )
    );
  }
  

  getData() async {
    try {
      setState(() {
        isLoading = true;
      });
      var userSnap = await FirebaseFirestore.instance
      .collection('users')
      .doc(widget.uid)
      .get();

      var postSnap = await FirebaseFirestore.instance
      .collection("posts")
      .where('uid', isEqualTo: widget.uid)
      .get();

      setState(() {
        userData = userSnap.data()!;
        postLen = postSnap.docs.length;
        isFollowing = userData['followers'].contains(FirebaseAuth.instance.currentUser!.uid);
        // postDatas = postSnap.docs.data()!;
        isLoading = false;
      });
    } catch (e) {
      showSnackBar(e.toString(), context);
    }
    setState(() {
        isLoading = false;
      });
  }

  Column buildStatColumn(int num, String label){
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          num.toString(), 
          style : TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            )
          ),
        Container(
          margin: const EdgeInsets.only(top:4),
          child: Text(
            label, 
            style : TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Colors.grey,
              )
            ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
      ? Center(
        child: CircularProgressIndicator(),
      )
      : Scaffold(
          appBar: AppBar(
            backgroundColor: mobileBackgroundColor,
            title: Text(userData['username']),
            centerTitle: false,
          ), 
          body: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.grey,
                          backgroundImage: NetworkImage(userData['photoURL']),
                          radius: 40,
                        ),
                        Expanded(
                          flex: 1,
                          child: Column(
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  buildStatColumn(postLen,"posts"),
                                  buildStatColumn(userData['followers'].length,"followers"),
                                  buildStatColumn(userData['following'].length,"following"),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  FirebaseAuth.instance.currentUser!.uid == widget.uid? 
                                  FollowButton(
                                    backgroundColor: mobileBackgroundColor, 
                                    borderColor: Colors.grey, 
                                    text: "SignOut", 
                                    textColor: Colors.white, 
                                    function: signOut,
                                    )
                                  : isFollowing?
                                  FollowButton(
                                    backgroundColor: mobileBackgroundColor, 
                                    borderColor: Colors.grey, 
                                    text: "UnFollow", 
                                    textColor: Colors.white, 
                                    function: followUnfollow
                                    )
                                  : FollowButton(
                                    backgroundColor: Colors.blue, 
                                    borderColor: Colors.blue, 
                                    text: "Follow", 
                                    textColor: Colors.white, 
                                    function: followUnfollow
                                    )
                          ],
                        ),
                            ],
                          ),
                        ),
                      ]
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(top:15,),
                      child: Text(userData['username'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold
                      ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(top:1),
                      child: Text(userData['bio'],
                      style: TextStyle(
                        fontWeight: FontWeight.w400
                      ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              StreamBuilder(
                stream: FirebaseFirestore.instance.collection('posts')
                .where("uid", isEqualTo: userData['uid']).snapshots(),
                builder: ((context, AsyncSnapshot<QuerySnapshot<Map<String,dynamic>>>snapshot) {
                  if(snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  return GridView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data!.docs.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 2,
                      childAspectRatio: 1
                      ),
                    itemBuilder: (context, index) {
                      DocumentSnapshot snap = snapshot.data!.docs[index];

                      return Container(
                        child: Image(
                          image: NetworkImage(snap['postURL']),
                        ),
                      );
                    }
                    );
                }),
                )
            ],
          ),
        );
  }
}