import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:instagram_flutter/models/user.dart';
import 'package:instagram_flutter/provider/user_provider.dart';
import 'package:instagram_flutter/resources/firestore_methods.dart';
import 'package:instagram_flutter/screens/comments_screen.dart';
import 'package:instagram_flutter/utils/colors.dart';
import 'package:instagram_flutter/utils/snack_bar_util.dart';
import 'package:instagram_flutter/widgets/like_animation.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PostCard extends StatefulWidget {
  final snap;
  const PostCard(
    {Key? key,
    required this.snap
    }) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {

  bool isLikeAnimating = false;
  int _numberOfComments = 0;

  void getNumberOfComments() async {
    QuerySnapshot commentData = await FirebaseFirestore
        .instance
        .collection('posts')
        .doc(widget.snap['postId'])
        .collection('comments').get();

    setState(() {
      _numberOfComments = commentData.docs.length;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getNumberOfComments();
  }

  @override
  Widget build(BuildContext context) {
    final User user = Provider.of<UserProvider>(context).getUser;
    return Container(
      color: mobileBackgroundColor,
      padding: const EdgeInsets.symmetric(
        vertical: 10,
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              vertical: 4,
              horizontal: 16
            ).copyWith(right: 0),
            child: Row(
              children: [
                CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(widget.snap['profImage']),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 8
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.snap['username'], 
                      style: TextStyle(
                        fontWeight: FontWeight.bold
                      ),
                      ),
                    ],
                  ),
                ),
                ),
                IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => Dialog(
                        child: ListView(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shrinkWrap: true,
                          children: [
                            "Delete"
                          ].map((e) => InkWell(
                            onTap: () async {
                                String res = await FireStoreMethods().deletePost(widget.snap['postId']);
                                if(res != "success"){
                                  showSnackBar(res,context);
                                }
                                Navigator.of(context).pop();
                              },
                              child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16,),
                              child: Text(e),
                            ),
                            ),
                          ).toList(),
                        ),
                      )
                      );
                  }, 
                  icon: const Icon(Icons.more_vert),
                  ),
              ],
            ),
          ),

          //Image Section of Post
          GestureDetector(
            onDoubleTap: () async {
              await FireStoreMethods().likePost(
                widget.snap['postId'],
                user.uid,
                widget.snap['likes'],
              );
              setState(() {
                isLikeAnimating = true;
              });
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
              height: MediaQuery.of(context).size.height*0.35,
              width: double.infinity,
              child: Image.network(widget.snap['postURL'],
                fit: BoxFit.cover,
              ),
                ),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isLikeAnimating ? 1 : 0,
                  child: LikeAnimation(
                    child: const Icon(
                    Icons.favorite, 
                    color: Colors.white,
                    size: 100,), isAnimating: isLikeAnimating,
                    duration: const Duration(milliseconds: 200),
                    onEnd: () {
                      setState(() {
                        isLikeAnimating = false;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

        Row(
          children: [
            LikeAnimation(
              isAnimating: widget.snap['likes'].contains(user.uid),
              smallLike: true,
              child: IconButton(
                onPressed: () async {
                  await FireStoreMethods().likePost(
                  widget.snap['postId'],
                  user.uid,
                  widget.snap['likes'],
                  );
                }, 
                icon: Icon(Icons.favorite,
                color: widget.snap['likes'].contains(user.uid)
                  ? Colors.red
                  : Colors.white,
                  )
                ),
            ),
            IconButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => CommentsScreen(
                    snap: widget.snap
                  ),
                  ),
                ), 
              icon: const Icon(Icons.comment)
              ),
            IconButton(
              onPressed: () {}, 
              icon: const Icon(Icons.share_rounded)
              ),
            Expanded(
              child: Align(
                alignment: Alignment.bottomRight,
                child: IconButton(
                  onPressed: () {}, 
                  icon: const Icon(Icons.bookmark_outline)
                  ),
                )
              ),
          ],
          ),
          // Comments & description
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 15
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DefaultTextStyle(
                  style: Theme.of(context).textTheme.subtitle2!.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                  child: Text(
                    "${widget.snap['likes'].length} likes",
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(top: 8),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(color: primaryColor),
                      children: [
                        TextSpan(
                          text: "${widget.snap['username']} ",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: widget.snap['description'],
                        ),
                      ],
                    ),
                    
                  ),
                ),

                InkWell(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text("View ${_numberOfComments} Comments",
                      style: TextStyle(fontSize: 16, color: secondaryColor),
                    ),
                  ),
                ),
                Container(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      DateFormat.yMMMd().format(widget.snap['datePublished'].toDate()),
                      style: TextStyle(fontSize: 16, color: secondaryColor),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      
    );
  }
}