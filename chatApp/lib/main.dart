//Flutter imports
import 'package:flutter/material.dart';

//Custom imports
import './screens/changePasswordScreen.dart';
import './screens/loginSignUpScreen.dart';
import './screens/profileScreeen.dart';
import './screens/settingScreen.dart';
import './screens/homeScreeen.dart';
import './config/settings.dart';
import './widgets/chat.dart';

void main() => runApp(ChatApp());

class ChatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: PRIMARY_COLOR,
        accentColor: ACCENT_COLOR,
      ),
      home: LoginScreen(),
      routes: {
        LoginScreen.routeName: (ctx) => LoginScreen(),
        HomeScreen.routeName: (ctx) => HomeScreen(),
        ChatScreen.routeName: (ctx) => ChatScreen(),
        SettingScreen.routeName: (ctx) => SettingScreen(),
        ProfileScreen.routeName: (ctx) => ProfileScreen(),
        ChangePassword.routeName: (ctx) => ChangePassword()
      },
    );
  }
}
