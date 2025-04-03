import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForumListPage extends StatefulWidget {
  @override
  _ForumListPageState createState() => _ForumListPageState();
}

class _ForumListPageState extends State<ForumListPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _forumController = TextEditingController();
  final List<Map<String, dynamic>> defaultForums = [
    {'name': 'Art', 'icon': Icons.palette},
    {'name': 'Music', 'icon': Icons.music_note},
    {'name': 'Beach Cleaning', 'icon': Icons.beach_access},
  ];

  void _createForum() async {
    if (_forumController.text.trim().isNotEmpty) {
      await FirebaseFirestore.instance.collection('forums').doc(_forumController.text).set({
        'name': _forumController.text,
        'createdBy': _auth.currentUser?.email ?? "Unknown",
        'timestamp': FieldValue.serverTimestamp(),
      });
      _forumController.clear();
      Navigator.of(context).pop();
    }
  }

  void _showCreateForumDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Create a New Forum"),
        content: TextField(
          controller: _forumController,
          decoration: InputDecoration(labelText: "Forum Name"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text("Cancel")),
          TextButton(onPressed: _createForum, child: Text("Create")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Forums"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _showCreateForumDialog,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('forums').orderBy('timestamp').snapshots(),
        builder: (context, snapshot) {
          List<Map<String, dynamic>> forums = defaultForums;
          if (snapshot.hasData) {
            forums.addAll(snapshot.data!.docs.map((doc) => {'name': doc['name'], 'icon': Icons.forum}).toList());
          }
          return ListView.builder(
            itemCount: forums.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: Icon(forums[index]['icon']),
                title: Text(forums[index]['name']),
                trailing: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatPage(forumName: forums[index]['name']),
                      ),
                    );
                  },
                  child: Text("Join"),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ChatPage extends StatefulWidget {
  final String forumName;
  ChatPage({required this.forumName});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _messageController = TextEditingController();

  void _sendMessage() async {
    if (_messageController.text.trim().isNotEmpty) {
      await FirebaseFirestore.instance.collection('chats').add({
        'text': _messageController.text,
        'sender': _auth.currentUser?.email ?? "Anonymous",
        'timestamp': FieldValue.serverTimestamp(),
        'forum': widget.forumName,
      });
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.forumName),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .where('forum', isEqualTo: widget.forumName)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                var messages = snapshot.data!.docs;
                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var message = messages[index].data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(message['text']),
                      subtitle: Text("By: ${message['sender']}"),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      labelText: "Enter Message",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blue),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
