//flutter imports
import 'package:flutter/material.dart';

//Third-party imports
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

//Custom imports
import '../config/settings.dart';
import '../config/userData.dart';

class SettingScreen extends StatefulWidget {
  static const String routeName = 'setting-screen';
  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool notificationSound;

  getNotificationSound() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      notificationSound = prefs.getBool('notificationSound') ?? false;
    });
  }

  final profileContainer = Container(
    padding: EdgeInsets.symmetric(vertical: 20),
    child: ListTile(
      leading: ClipOval(
        child: Image.asset('assets/images/user.jpg'),
      ),
      title: Text(
        'Name:${User.firstName}',
        style: TextStyle(color: TEXT_COLOR, fontSize: 24),
      ),
      subtitle: Text(
        User.email,
        style: TextStyle(color: TEXT_COLOR, fontSize: 16),
      ),
    ),
  );

  //delete account option container
  Widget deleteAccountContainer() {
    return ListTile(
      leading: Icon(
        Icons.person,
        color: PRIMARY_COLOR,
      ),
      title: Text('Delete My Account'),
      onTap: () async {
        FirebaseUser user = await FirebaseAuth.instance.currentUser();
        user.delete().then((_) {
          Navigator.popUntil(context, ModalRoute.withName('login-screen'));
        });
      },
    );
  }

  //Help option Container
  Widget helpContainer() {
    return ListTile(
      leading: Icon(
        Icons.help,
        color: PRIMARY_COLOR,
      ),
      title: Text('Help'),
      onTap: () {
        showHelpPage();
      },
    );
  }

//Show help page for the help feature.
  showHelpPage() {
    return showDialog(
        barrierDismissible: false,
        context: context,
        child: AlertDialog(
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          title: Text('Help!'),
          content: Container(
            height: MediaQuery.of(context).size.height * 0.5,
            width: MediaQuery.of(context).size.width * 1.5,
            padding: EdgeInsets.all(10),
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Text(
                      "Lorem Ipsum is simply dummy text of the printing and typesetting"),
                  Text(
                      "Lorem Ipsum has been the industrys standard dummy text ever"),
                  Text(
                      "Lorem Ipsum has been the industrys standard dummy text ever"),
                  Text(
                      "Lorem Ipsum has been the industrys standard dummy text ever"),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            RaisedButton(
                color: PRIMARY_COLOR,
                child: Text('OK'),
                onPressed: () {
                  Navigator.pop(context);
                }),
          ],
        ));
  }

//Divider line
  final divider = Divider(
    indent: 10,
    endIndent: 10,
    thickness: 1,
  );
  @override
  void initState() {
    super.initState();
    getNotificationSound();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        children: <Widget>[
          profileContainer,
          Divider(
            indent: 10,
            endIndent: 10,
            thickness: 1.5,
          ),
          ListTile(
            leading: Icon(
              notificationSound
                  ? Icons.notifications_active
                  : Icons.notifications_off,
              color: PRIMARY_COLOR,
            ),
            title: Text('Notification Sound'),
            trailing: Switch(
              value: notificationSound,
              activeColor: Colors.white,
              activeTrackColor: Colors.green,
              onChanged: (value) {
                setState(() {
                  notificationSound = value;
                  setNotificationSound(value);
                });
              },
            ),
          ),
          divider,
          ListTile(
            leading: Icon(
              Icons.vpn_key,
              color: PRIMARY_COLOR,
            ),
            title: Text('Change Password'),
            onTap: () {
              Navigator.pushNamed(context, 'change-password-screen');
            },
          ),
          divider,
          deleteAccountContainer(),
          divider,
          helpContainer()
        ],
      ),
    );
  }
}

//set nofitication sound in the shared preferences.
setNotificationSound(value) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setBool('notificationSound', value);
}
