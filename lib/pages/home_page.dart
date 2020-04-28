import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Home'),
        ),
        body: Column(
          children: <Widget>[
            SizedBox(height: 20,),
            Text('首页'),
            SizedBox(height: 20,),
            RaisedButton(
              child: Text('clickMe'),
              onPressed: () {
                print("button clicked");
              },
            )
          ],
        ));
  }
}
