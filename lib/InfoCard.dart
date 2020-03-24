import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {
  const InfoCard({Key key, this.total_cases, this.title, this.color, this.icon})
      : super(key: key);

  final int total_cases;
  final String title;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 3, horizontal: 3),
      color: color,
      child: Container(
        height: 90.0,
        padding: EdgeInsets.all(5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Icon(
              icon,
              size: 25,
            ),
            Text(
              total_cases.toString(),
              style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
