import 'package:flutter/material.dart';
class summery extends StatefulWidget {
  const summery({Key? key}) : super(key: key);

  @override
  _summeryState createState() => _summeryState();
}

class _summeryState extends State<summery> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.insert_chart_outlined,color:Colors.blue,size:70),
          SizedBox(height:10),
          Text('Summery'),
        ],
      ),
    );
  }
}
