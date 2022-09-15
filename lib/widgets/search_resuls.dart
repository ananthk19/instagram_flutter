import 'package:flutter/material.dart';
import 'package:instagram_flutter/screens/profile_screen.dart';

class SearchResults extends StatefulWidget {
  final snap;
  SearchResults(
    {Key? key,
    required this.snap
    }) : super(key: key);

  @override
  _SearchResultsState createState() => _SearchResultsState();
}

class _SearchResultsState extends State<SearchResults> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ProfileScreen(
              uid: widget.snap['uid']
              )
            )
        );
      },
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(widget.snap['photoURL']),
          radius: 16,
        ),
        title: Text(widget.snap['username']),
      ),
    );
  }
}