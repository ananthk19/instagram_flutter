import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_flutter/screens/add_posts_screen.dart';
import 'package:instagram_flutter/screens/feed_screen.dart';
import 'package:instagram_flutter/screens/profile_screen.dart';
import 'package:instagram_flutter/screens/search_screen.dart';

const WebScreenSize = 600;

var homeScreenItems = [
              FeedScreen(),
              SearchScreen(),
              AddPostsScreen(),
              Center(child: Text("Notifs")),
              ProfileScreen(uid: FirebaseAuth.instance.currentUser!.uid),
];