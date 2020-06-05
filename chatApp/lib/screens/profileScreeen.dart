//Flutter imports.
import 'package:flutter/material.dart';
import 'dart:convert';

//Third-party imports.
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:http/http.dart' as http;

//Custom imports.
import '../widgets/message.dart';
import '../config/settings.dart';
import '../config/userData.dart';
import '../config/env.dart';

class ProfileScreen extends StatefulWidget {
  static const String routeName = 'profile-screen';
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var nameController = TextEditingController();
  var descriptionController = TextEditingController();

  bool _isLoading = false;
  bool _isChanged = false;

  //Profile image container
  Widget profileImg() {
    return Center(
      child: Container(
        margin: EdgeInsets.only(top: 20),
        height: 200,
        width: 200,
        child: ClipOval(
          child: Image.asset(
            'assets/images/user.jpg',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  //About field container for status
  Widget showNameContainer() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        autofocus: false,
        controller: nameController,
        onChanged: (value) {
          value.isEmpty
              ? setState(() {
                  _isChanged = false;
                })
              : setState(() {
                  _isChanged = true;
                });
        },
        decoration: InputDecoration(
          hintText: 'Enter Your Name',
          suffixIcon: Icon(Icons.edit),
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

//Description field container.
  Widget showDescriptionContainer() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        autofocus: false,
        onChanged: (value) {
          value.isEmpty
              ? setState(() {
                  _isChanged = false;
                })
              : setState(() {
                  _isChanged = true;
                });
        },
        decoration: InputDecoration(
          hintText: 'Bio',
          suffixIcon: Icon(Icons.edit),
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

//Show save button.
  Widget showSaveButton() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: SizedBox(
        height: 40,
        child: RaisedButton(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          color: PRIMARY_COLOR,
          child: Text(
            'Save',
            style: TextStyle(color: ACCENT_COLOR, fontSize: 20.0),
          ),
          onPressed: () {
            FocusScope.of(context).requestFocus(new FocusNode());
            setState(() {
              _isLoading = true;
              onSaveData();
            });
          },
        ),
      ),
    );
  }

  //On Save data.
  void onSaveData() {
    const url = UPDATE_PROFILE_URL;

    http
        .post(url,
            body: jsonEncode({
              "idToken": User.idToken,
              "displayName": nameController.text,
              "photoUrl": "[URL]",
              "returnSecureToken": true
            }))
        .then((value) {
      setState(() {
        _isLoading = false;
        _isChanged = false;
      });
      var response = jsonDecode(value.body);
      if (response['localId'] != null) {
        Message()
            .information(context, 'Success!', 'Profile updated successfully!');
      }
      print('profile Reponse:${response['displayName']}');
    });
  }

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: User.firstName);
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: _isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Profile'),
        ),
        body: ListView(
          shrinkWrap: true,
          children: <Widget>[
            profileImg(),
            SizedBox(height: 40),
            showNameContainer(),
            SizedBox(
              height: 20,
            ),
            showDescriptionContainer(),
            _isChanged ? showSaveButton() : Container(),
          ],
        ),
      ),
    );
  }
}
