import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver/widgets/MainButton.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late CollectionReference _messagesCollection;

  String _currentUser = 'User1'; // Replace with the logged-in user's name
  String _otherUser = 'User2'; // Replace with the other user's name

  @override
  void initState() {
    super.initState();
    _messagesCollection = _firestore.collection('messages');
  }

  void _sendMessage(String text) async {
    await _messagesCollection.add({
      'text': text,
      'sender': _currentUser,
      'receiver': _otherUser,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
    _textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _messagesCollection
                  .where('sender', whereIn: [_currentUser, _otherUser])
                 // .where('receiver', whereIn: [_currentUser, _otherUser])
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                final messages = snapshot.data?.docs;
                return ListView.builder(
                  itemCount: messages?.length,
                  itemBuilder: (context, index) {
                    final message = messages?[index].data().toString();
                    return ListTile(
                      title: Text(message!),
                      //subtitle: Text(message['sender']),
                     // trailing: Text(message!['timestamp'].toString()),
                    );
                  },
                );
              },
            ),
          ),
          Divider(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Enter a message...',
                    ),
                  ),
                ),
                MainButton(
                  onPressed: () {
                    _sendMessage(_textController.text);
                  },
                  child: Text('Send'),
                  color: Colors.blue,
                  //textColor: Colors.white,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}