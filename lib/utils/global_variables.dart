import 'package:flutter/material.dart';
import 'package:instagram_flutter/screens/add_posts_screen.dart';
import 'package:instagram_flutter/screens/feed_screen.dart';

const WebScreenSize = 600;

var homeScreenItems = [
              FeedScreen(),
              Center(child: Text("Search")),
              AddPostsScreen(),
              Center(child: Text("Notifs")),
              Center(child: Text("Profile")),
];