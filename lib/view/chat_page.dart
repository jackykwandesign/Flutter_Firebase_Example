import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_flutter_1/firebase_utils/firestoreConstant.dart';
import 'package:firebase_flutter_1/firebase_utils/firestore_listener.dart';
import 'package:firebase_flutter_1/model/chatroom.model.dart';
import 'package:flutter/material.dart';

class ChatroomPage extends StatefulWidget {
  const ChatroomPage({Key? key}) : super(key: key);

  @override
  State<ChatroomPage> createState() => _ChatroomPageState();
}

class _ChatroomPageState extends State<ChatroomPage> {
  bool isInitFirestoreListener = false;
  final db = FirebaseFirestore.instance;
  List<Chatroom> chatrooms = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
      ),
      body: ListView.separated(
        separatorBuilder: (BuildContext context, int index) => const Divider(
          color: Colors.grey,
          height: 1,
        ),
        itemBuilder: (_, int index) {
          Chatroom chatroom = chatrooms[index];
          return Row(
            children: [],
          );
          return Text('asd');
        },
        itemCount: chatrooms.length,
      ),
    );
  }

  // subscribe to firestore
  firestoreListenerInit() {
    debugPrint('Init firestore listener');
    firestoreListener(db, FC.chatrooms.value, chatrooms, setState);
    setState(() {
      isInitFirestoreListener = true;
    });
  }
}
