import "package:flutter/material.dart";

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({
    Key key,
    @required this.title,
  }) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CircularProgressIndicator(
            strokeWidth: 2.0,
          ),
          Text(title.toLowerCase() + "..."),
        ],
      ),
    );
  }
}
