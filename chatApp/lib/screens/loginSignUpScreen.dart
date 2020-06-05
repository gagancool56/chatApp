//flutter imports
import 'package:flutter/material.dart';

//Third-party imports
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

//Custom imports
import '../widgets/message.dart';
import '../config/userData.dart';
import '../config/settings.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = 'login-screen';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final Firestore _firestore = Firestore.instance;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isLoginForm = true;
  bool _isForgetPassword = false;
  String _email;
  String _password;

//Show logo on the screen
  Widget showLogo() {
    return Hero(
      tag: 'logo',
      child: Padding(
        padding: EdgeInsets.fromLTRB(0.0, 70.0, 0.0, 0.0),
        child: CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: 48.0,
          child: Image.asset('assets/images/logo.png'),
        ),
      ),
    );
  }

  //Show Email input field
  Widget showEmailInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 0.0),
      child: TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        autofocus: false,
        decoration: InputDecoration(
            hintText: 'Email',
            icon: Icon(
              Icons.mail,
              color: Colors.grey,
            )),
        validator: (value) => value.isEmpty ? 'Email can\'t be empty' : null,
        onSaved: (value) => _email = value.trim(),
      ),
    );
  }

// show Password input field
  Widget showPasswordInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: TextFormField(
        maxLines: 1,
        obscureText: true,
        autofocus: false,
        decoration: InputDecoration(
            hintText: 'Password',
            icon: Icon(
              Icons.lock,
              color: Colors.grey,
            )),
        validator: (value) => value.isEmpty ? 'Password can\'t be empty' : null,
        onSaved: (value) => _password = value.trim(),
      ),
    );
  }

//After the login data submitted
  login(String _email, String _password) async {
    FirebaseAuth _auth = FirebaseAuth.instance;

    await _auth
        .signInWithEmailAndPassword(
      email: _email,
      password: _password,
    )
        .then((value) {
      print(value);
      print(value.user.uid);
      if (value.user.isEmailVerified == true) {
        User.email = value.user.email;
        User.firstName = value.user.displayName;

        setState(() async {
          _isLoading = false;
          final Future<QuerySnapshot> query = Firestore.instance
              .collection('Users')
              .where('email', isEqualTo: User.email)
              .getDocuments();
          query.then((value) {
            value.documents.map((e) => User.idToken = e.documentID).toString();
            print('user id token:${User.idToken}');
          });

          SharedPreferences pref = await SharedPreferences.getInstance();
          pref.setString('id', User.idToken).then((_) {
            Navigator.of(context).pushReplacementNamed('home-screen');
          });
        });
      } else if (value.user.isEmailVerified == false) {
        setState(() {
          _isLoading = false;
          Message().information(context, 'Alert!', 'Email id is not verified!');
        });
      }
    });
  }

//Signup method.
  signUp(String _email, String _password) async {
    final FirebaseAuth _auth = FirebaseAuth.instance;

    await _auth
        .createUserWithEmailAndPassword(
      email: _email,
      password: _password,
    )
        .then((value) {
      if (value.user != null) {
        //saving the user data into the firestore.

        _firestore.collection('Users').add({
          'firstName': value.user.displayName,
          'email': value.user.email,
          'profileImage': value.user.photoUrl
        }).then((_) {
          //sending email verification link to the user.
          value.user.sendEmailVerification().then((_) {
            setState(() {
              _isLoginForm = true;
              _isLoading = false;
              Message().information(context, 'Success!',
                  'A Email verification link has been sent to your email');
            });
          });
        });
      }
    });
  }

  //show Login button
  Widget showPrimaryButton() {
    return Padding(
        padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
        child: SizedBox(
          height: 40.0,
          child: RaisedButton(
            elevation: 5.0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0)),
            color: PRIMARY_COLOR,
            child: _isForgetPassword
                ? Text('Send Email',
                    style: TextStyle(fontSize: 20.0, color: ACCENT_COLOR))
                : Text(_isLoginForm ? 'Login' : 'Create account',
                    style: TextStyle(fontSize: 20.0, color: ACCENT_COLOR)),
            onPressed: () {
              if (_formKey.currentState.validate()) {
                setState(() {
                  _isLoading = true;
                });
                _formKey.currentState.save();
                FocusScope.of(context).requestFocus(new FocusNode());
                if (_isLoginForm == true && _isForgetPassword == false) {
                  login(_email, _password);
                } else if (_isForgetPassword == true) {
                  resetPassword(_email);
                } else {
                  signUp(_email, _password);
                }
              }
            },
          ),
        ));
  }

  //Reset password function.
  resetPassword(_email) async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    _auth.sendPasswordResetEmail(email: _email).then((_) {
      setState(() {
        _isLoading = false;
        _isForgetPassword = false;
        Message().information(
            context, 'Alert!', 'Password reset email has been sent!');
      });
    });
  }

//Show Register button
  Widget showSecondaryButton() {
    return FlatButton(
        child: Text(
            _isLoginForm ? 'Create an account' : 'Have an account? Sign in',
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w300)),
        onPressed: toggleFormMode);
  }

  //Show forget password Button.
  Widget showForgetPasswordButton() {
    return _isLoginForm
        ? FlatButton(
            child: Text('Forget Password ?',
                style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w400,
                    color: PRIMARY_COLOR)),
            onPressed: () {
              setState(() {
                _isForgetPassword = true;
              });
            })
        : Container();
  }

//Toggle form for register and login
  void toggleFormMode() {
    _formKey.currentState.reset();
    setState(() {
      _isLoginForm = !_isLoginForm;
    });
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
              showEmailInput(),
              _isForgetPassword ? Container() : showPasswordInput(),
              showPrimaryButton(),
              _isForgetPassword ? Container() : showForgetPasswordButton(),
              _isForgetPassword ? Container() : showSecondaryButton(),
            ],
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat App'),
      ),
      body: WillPopScope(
        onWillPop: onWillPop,
        child: ModalProgressHUD(
          inAsyncCall: _isLoading,
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

//Double press back button to exit the app.
DateTime backPressedTime;
Future<bool> onWillPop() async {
  DateTime currentTime = DateTime.now();
  if (backPressedTime == null ||
      currentTime.difference(backPressedTime) > Duration(seconds: 3)) {
    backPressedTime = currentTime;
    Fluttertoast.showToast(
        msg: 'Press again to exit!',
        gravity: ToastGravity.BOTTOM,
        backgroundColor: PRIMARY_COLOR,
        textColor: ACCENT_COLOR,
        fontSize: 22);
    return false;
  }
  return true;
}
