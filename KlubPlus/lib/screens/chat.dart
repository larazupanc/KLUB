import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessage {
  final String email;
  final String message;
  final Timestamp timestamp;

  ChatMessage({required this.email, required this.message, required this.timestamp});

  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return ChatMessage(
      email: data['email'] ?? '',
      message: data['message'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }
}

class GroupChatScreen extends StatefulWidget {
  final String userEmail; // Accept email as a parameter

  GroupChatScreen({required this.userEmail});

  @override
  _GroupChatScreenState createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  Future<void> _sendMessage(String email) async {
    if (_messageController.text.trim().isEmpty) return;

    await FirebaseFirestore.instance.collection('groupChat').add({
      'email': email, // Use the passed email here
      'message': _messageController.text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
    });

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Skupina'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('groupChat')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                List<ChatMessage> messages = snapshot.data!.docs
                    .map((doc) => ChatMessage.fromFirestore(doc))
                    .toList();

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    ChatMessage message = messages[index];

                    bool isCurrentUser = message.email == widget.userEmail;

                    return Align(
                      alignment:
                      isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Material(
                          borderRadius: BorderRadius.circular(10),
                          color: isCurrentUser
                              ? Colors.blueAccent
                              : Colors.grey.shade200,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 10.0),
                            child: Column(
                              crossAxisAlignment: isCurrentUser
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                Text(
                                  message.email,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isCurrentUser
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  message.message,
                                  style: TextStyle(
                                    color: isCurrentUser
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  message.timestamp
                                      .toDate()
                                      .toString()
                                      .substring(11, 16),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isCurrentUser
                                        ? Colors.white70
                                        : Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
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
                      labelText: 'Vpiši sporočilo...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () => _sendMessage(widget.userEmail), // Pass email here
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
