//Flutter imports.
import 'package:flutter/material.dart';

//Third-party imports.
import 'package:cloud_firestore/cloud_firestore.dart';

//Custom imports.
import '../config/userData.dart';
import '../config/settings.dart';

class ChatScreen extends StatefulWidget {
  static const String routeName = 'chat-screen';
  final String name;
  final String email;
  final String chatUserId;

  const ChatScreen({this.name, this.email, this.chatUserId});

  @override
  _ChatScreenState createState() =>
      _ChatScreenState(name: name, email: email, chatUserId: chatUserId);
}

class _ChatScreenState extends State<ChatScreen> {
  String name;
  String email;
  String chatUserId;

  _ChatScreenState({this.name, this.email, this.chatUserId});

  final Firestore _firestore = Firestore.instance;
  TextEditingController messageController = TextEditingController();
  ScrollController scrollController = ScrollController();
  String loginUserId = User.idToken;
  String chatId;

  getChatId() {
    if (loginUserId.hashCode <= chatUserId.hashCode) {
      chatId = loginUserId + chatUserId;
    } else {
      chatId = chatUserId + loginUserId;
    }
  }

  //container for Type a message.
  Widget roundedContainer() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.0),
      child: Container(
        color: Colors.white,
        child: Row(
          children: <Widget>[
            SizedBox(width: 8.0),
            Icon(Icons.insert_emoticon, size: 30.0, color: PRIMARY_COLOR),
            SizedBox(width: 8.0),
            Expanded(
              child: TextField(
                controller: messageController,
                decoration: InputDecoration(
                  hintText: 'Type a message',
                  border: InputBorder.none,
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.send),
              iconSize: 30.0,
              color: PRIMARY_COLOR,
              onPressed: () {
                sendMessage();
              },
            ),
            SizedBox(width: 8.0),
          ],
        ),
      ),
    );
  }

  Future<void> sendMessage() async {
    if (loginUserId.length < chatUserId.length) {
      chatId = loginUserId + chatUserId;
    } else if (loginUserId.length > chatUserId.length) {
      chatId = chatUserId + loginUserId;
    }

    if (messageController.text.length > 0) {
      //checking if id already exists in the message collection.
      if (Firestore.instance.collection('messages').document().documentID ==
          chatId) {
        await _firestore
            .collection('messages')
            .document(chatId)
            .collection(chatId)
            .document()
            .updateData({
          'text': messageController.text,
          'sender_receiver': [User.email, email],
          'timeStamp': DateTime.now(),
        });
      } else {
        await _firestore
            .collection('messages')
            .document(chatId)
            .collection(chatId)
            .document()
            .setData({
          'text': messageController.text,
          'sender_receiver': [User.email, email],
          'timeStamp': DateTime.now(),
        });
      }

      messageController.clear();
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    getChatId();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        actions: <Widget>[
          Icon(Icons.more_vert),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('messages')
                    .document(chatId)
                    .collection(chatId)
                    .orderBy('timeStamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return Center();

                  List<DocumentSnapshot> docs = snapshot.data.documents;

                  List<Widget> messages = docs
                      .map((doc) => Chats(
                            me: doc.data['sender_receiver'][0] == User.email
                                ? true
                                : false,
                            senderId: doc.data['sender_receiver'][0],
                            text: doc.data['text'],
                          ))
                      .toList();

                  return ListView(
                    controller: scrollController,
                    children: <Widget>[
                      ...messages.reversed,
                    ],
                  );
                }),
          ),
          Container(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: roundedContainer(),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class Chats extends StatelessWidget {
  final String text;
  final String senderId;
  final bool me;

  const Chats({Key key, this.text, this.me, this.senderId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment:
            me ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Text(senderId,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: me ? Colors.red[100] : Colors.green[100],
            ),
            child: Text(text,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
