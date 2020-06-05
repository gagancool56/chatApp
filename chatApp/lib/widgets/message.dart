import 'package:flutter/material.dart';

class Message {
  information(BuildContext context, String title, String description) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: TextStyle(color: Colors.redAccent, fontSize: 20),
          ),
          content: SingleChildScrollView(
              child: ListBody(
            children: <Widget>[
              Text(
                description,
                style: TextStyle(fontSize: 18),
              ),
            ],
          )),
          actions: <Widget>[
            RaisedButton(
              color: Colors.red,
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            )
          ],
        );
      },
    );
  }
}
