import 'package:flutter/material.dart';

class TestPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _TestPage();
  }
}


class _TestPage extends State<TestPage> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 50,
        ),
        Text('$index'),
        Container(
          width: 200,
          height: 50,
          child: RaisedButton.icon(
            icon: Icon(Icons.repeat),
            label: Text('click me'),
//            child: Text('click me'),
            color: Colors.blue,
            textColor: Colors.white,
            elevation: 100,
            onPressed: () {
              setState(() {
                index++;
              });
            },
          ),
        )
      ],
    );
  }
}
