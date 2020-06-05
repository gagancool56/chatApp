//flutter imports
import 'package:flutter/material.dart';

//Third-party imports
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

//Custom imports
import '../widgets/message.dart';
import '../config/settings.dart';
import '../config/userData.dart';

class ChangePassword extends StatefulWidget {
  static const String routeName = 'change-password-screen';
  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String _newPassword;
  String _confirmPassword;

//Show logo on the screen
  Widget showLogo() {
    return Hero(
      tag: 'logo',
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 48.0,
        child: Image.asset('assets/images/logo.png'),
      ),
    );
  }

// Show Old Password input field
  Widget showOldPasswordInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: TextFormField(
        maxLines: 1,
        obscureText: true,
        autofocus: false,
        decoration: InputDecoration(
          hintText: 'Old Password',
        ),
        validator: (value) {
          if (value.isEmpty) {
            return 'Old Password can\'t be empty';
          } else if (value != User.password) {
            return 'Old password is Invalid!';
          }
          return null;
        },
      ),
    );
  }

  //Show New Password input field.
  Widget showNewPasswordInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: TextFormField(
        maxLines: 1,
        obscureText: true,
        autofocus: false,
        decoration: InputDecoration(
          hintText: 'New Password',
        ),
        validator: (value) {
          _newPassword = value;
          if (value.isEmpty) {
            return 'New Password can\'t be empty';
          }
          return null;
        },
        onSaved: (value) => _newPassword = value.trim(),
      ),
    );
  }

  //Show Confirm password input field.
  Widget showConfirmPasswordInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: TextFormField(
        maxLines: 1,
        obscureText: true,
        autofocus: false,
        decoration: InputDecoration(
          hintText: 'Confirm Password',
        ),
        validator: (value) {
          if (value.isEmpty) {
            return 'Confirm Password can\'t be empty';
          } else if (value != _newPassword) {
            return 'Confirm Password and New password should be same';
          }
          return null;
        },
        onSaved: (value) => _confirmPassword = value.trim(),
      ),
    );
  }

//Change password method.
  changePassword(String password) async {
    FirebaseUser _user = await FirebaseAuth.instance.currentUser();
    _user.updatePassword(password).then((value) {
      setState(() {
        _isLoading = false;
        Message()
            .information(context, 'Success!', 'Password changed successFully!');
      });
    });
  }

//Logout and clear sharedPreferences.
  logoutAndClearSharedPreferences() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.remove('idToken').then((value) {
      setState(() {
        _isLoading = false;
        Navigator.of(context).pushReplacementNamed('login-screen');
      });
    });
  }

  //show Login button
  Widget showChangePasswordButton() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
      child: SizedBox(
        height: 40.0,
        child: RaisedButton(
          elevation: 5.0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
          color: PRIMARY_COLOR,
          child: Text('Change Password',
              style: TextStyle(fontSize: 20.0, color: ACCENT_COLOR)),
          onPressed: () {
            if (_formKey.currentState.validate()) {
              setState(() {
                _isLoading = true;
              });
              _formKey.currentState.save();
              FocusScope.of(context).requestFocus(new FocusNode());
              changePassword(_confirmPassword);
            }
            return null;
          },
        ),
      ),
    );
  }

//Show form
  Widget _showForm() {
    return Container(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              showLogo(),
              showOldPasswordInput(),
              showNewPasswordInput(),
              showConfirmPasswordInput(),
              showChangePasswordButton(),
            ],
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Change Password'),
      ),
      body: ModalProgressHUD(
        inAsyncCall: _isLoading,
        child: Center(
          child: Stack(
            children: <Widget>[
              _showForm(),
            ],
          ),
        ),
      ),
    );
  }
}
