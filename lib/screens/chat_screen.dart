import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../consts.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;
List<MessageBubble> here = [];
User loggedInUser;

class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _auth = FirebaseAuth.instance;
  final controller = TextEditingController();

  String messageText;

  @override
  void initState() {
    super.initState();
    getCurrentuser();
  }

  void getCurrentuser() async {
    final user = _auth.currentUser;
    if (user != null) {
      loggedInUser = user;
      print(loggedInUser.email);
    }
  }

  void getStreamsofMessages() async {
    await for (var snapShots in firestore.collection('messages').snapshots()) {
      for (var messages in snapShots.docs) {
        print(messages);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Color(0xff64FFDA),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessageStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: controller,
                      onChanged: (value) {
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      controller.clear();
                      firestore.collection('messages').add({
                        'text': messageText,
                        'sender': loggedInUser.email,
                        'time': Timestamp.now(),
                      });
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: firestore
            .collection('messages')
            .orderBy('time', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.lightBlueAccent,
              ),
            );
          }
          {
            final messages = snapshot.data.docs;
            List<MessageBubble> messageBubbles = [];
            for (var message in messages) {
              final messageText = message.data()['text'];
              final messageSender = message.data()['sender'];
              final messageTime = message.data()['time'];
              dynamic currentUser = loggedInUser.email;
              dynamic messageBubble = MessageBubble(
                sender: messageSender,
                text: messageText,
                isMe: currentUser == messageSender,
                time: messageTime,
              );
              messageBubbles.add(messageBubble);
            }
            here = messageBubbles;
          }
          return Expanded(
            child: ListView(
              reverse: true,
              children: here,
            ),
          );
        });
  }
}

class MessageBubble extends StatelessWidget {
  final sender;
  final text;
  final bool isMe;
  final time;

  MessageBubble({this.sender, this.text, this.isMe, this.time});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Material(
            elevation: 5,
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(20), bottomLeft: Radius.circular(20)),
            color: isMe ? Colors.tealAccent[700] : Colors.black38,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 15.0),
              child: Text(
                '$text',
                style: TextStyle(fontSize: 15.0, color: Colors.white),
              ),
            ),
          ),
          Text(
            DateFormat('kk:mm:a').format((time as Timestamp).toDate()),
            style: TextStyle(color: Colors.grey, fontSize: 8.0),
            //DateFormat.yMMMEd().format((time as Timestamp).toDate()),
          ),
          Text(
            sender,
            style: TextStyle(color: Colors.grey, fontSize: 8.0),
          ),
        ],
      ),
    );
  }
}
