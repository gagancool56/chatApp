//Flutter imports.
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';

//Third-party imports.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

//Custom imports
import '../widgets/chat.dart';
import '../config/settings.dart';
import '../config/userData.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = 'home-screen';
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
//Drawer widget created here.
  Widget userDrawer() {
    return Drawer(
      child: ListView(
        children: <Widget>[
          Container(
            height: 100,
            child: DrawerHeader(
              child: ListTile(
                leading: ClipOval(
                  child: Image.asset('assets/images/user.jpg'),
                ),
                title: Text(
                  'name:${User.firstName}',
                  style: TextStyle(color: ACCENT_COLOR),
                ),
                subtitle: Text(
                  User.email,
                  style: TextStyle(color: ACCENT_COLOR),
                ),
              ),
              decoration: BoxDecoration(color: PRIMARY_COLOR),
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.person,
              color: PRIMARY_COLOR,
            ),
            title: Text('Profile'),
            onTap: () {
              Navigator.of(context).pushNamed('profile-screen');
            },
          ),
          ListTile(
            leading: Icon(
              Icons.help,
              color: PRIMARY_COLOR,
            ),
            title: Text('Help'),
          ),
          ListTile(
            leading: Icon(Icons.notifications, color: PRIMARY_COLOR),
            title: Text('Notifications'),
          ),
          ListTile(
            leading: Icon(
              Icons.settings,
              color: PRIMARY_COLOR,
            ),
            title: Text('Settings'),
            onTap: () {
              Navigator.of(context).pushNamed('setting-screen');
            },
          ),
          Divider(
            indent: 20,
            endIndent: 20,
            color: Colors.grey,
          ),
          ListTile(
            title: Text('Logout'),
            leading: Icon(
              Icons.exit_to_app,
              color: PRIMARY_COLOR,
            ),
            onTap: () {
              logout();
            },
          ),
        ],
      ),
    );
  }

//loging out the user from the app and sending back to the login screen.
  logout() {
    FirebaseAuth.instance.signOut().then((value) {
      Navigator.pushNamedAndRemoveUntil(
          context, 'login-screen', (route) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: userDrawer(),
        appBar: AppBar(
          title: Text('ChatApp'),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  showSearch(context: context, delegate: SearchContacts());
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Icon(Icons.add_box),
            ),
          ],
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                  stream: Firestore.instance
                      .collection('Users')
                      .orderBy('email')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return Center();
                    List<DocumentSnapshot> docs = snapshot.data.documents;
                    List<Widget> contacts = docs
                        .map((doc) => HomeContacts(
                              senderId: doc.data['email'],
                              name: doc.data['fullName'],
                              profileImg: doc.data['profileImage'],
                            ))
                        .toList();
                    return ListView(
                      children: <Widget>[...contacts],
                    );
                  }),
            )
          ],
        ));
  }
}

//get the messages details;
getFriendsFromMessages() {
  List singleEmailList = [];

  //fetching only the message object which contains only the particular email.
  final Future<QuerySnapshot> collectionReference = Firestore.instance
      .collection('messages')
      .where('sender_receiver', arrayContainsAny: [User.email])
      .reference()
      .getDocuments();

  collectionReference.then((value) {
    //Mapping the documents value to convert it into a list.
    List emailList =
        value.documents.map((e) => e.data['sender_receiver']).toList();

    print('email list:$emailList');
    //Coverting the list of list email ids into a single list.
    for (int i = 0; i < emailList.length; i++) {
      for (int j = 0; j < emailList[i].length; j++) {
        singleEmailList.add(emailList[i][j]);
      }
    }

    //Finding the distinct email ids only.
    List distinctEmails = singleEmailList.toSet().toList();

    //Removing the currently logged in user from the list.
    distinctEmails.remove(User.email);

    //passingt values to the getUsersList method.
    print('final email:$distinctEmails');

    return distinctEmails;
    // print('From get all message:$distinctEmails');
  });
}

class HomeContacts extends StatelessWidget {
  final String name;
  final String senderId;
  final String profileImg;

  const HomeContacts({Key key, this.name, this.senderId, this.profileImg})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return User.email != senderId
        ? Container(
            child: Card(
              elevation: 3,
              child: ListTile(
                leading: ClipOval(
                  child: Image.memory(
                    base64Decode(profileImg),
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(name),
                subtitle: Text(senderId),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () {
                  final Future<QuerySnapshot> user = Firestore.instance
                      .collection('Users')
                      .where('email', isEqualTo: senderId)
                      .getDocuments();

                  user.then((value) {
                    String currentChatUserId;
                    value.documents
                        .map((e) => currentChatUserId = (e.documentID))
                        .toString();
                    print(' chat id :-$currentChatUserId');

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          name: name,
                          email: senderId,
                          chatUserId: currentChatUserId,
                        ),
                      ),
                    );
                  });
                },
              ),
            ),
          )
        : Container();
  }
}

//Data search
class SearchContacts extends SearchDelegate<String> {
  List contact = [
    'Aman',
    'Baljit',
    'Charanjit',
    'Daman',
    'Enthe',
    'Amarjit Singh'
  ];

  final suggestion = ['Aman', 'Charanjit'];
  @override
  List<Widget> buildActions(BuildContext context) {
    //action for app bar
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestionList = query.isEmpty
        ? suggestion
        : contact.where((p) => p.startsWith(query)).toList();
    return ListView.builder(
      itemBuilder: (context, index) => ListTile(
        leading: Icon(Icons.contacts),
        title: Text(suggestionList[index]),
      ),
      itemCount: suggestionList.length,
    );
  }
}
