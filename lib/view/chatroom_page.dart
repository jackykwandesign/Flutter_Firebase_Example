import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_flutter_1/firebase_utils/firestore_constant.dart';
import 'package:firebase_flutter_1/model/chatroom.model.dart';
import 'package:firebase_flutter_1/view/user_chat_page.dart';
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
  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    getChatrooms();
    // if (!isInitFirestoreListener) {
    //   firestoreListenerInit();
    // }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (chatrooms.isEmpty) {
      return const Center(child: Text('No Chatrooms'));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('ChatRooms'),
      ),
      body: Column(
        children: [
          Text(currentUser!.uid),
          Expanded(
            child: ListView.separated(
              separatorBuilder: (BuildContext context, int index) =>
                  const Divider(
                color: Colors.grey,
                height: 1,
              ),
              itemBuilder: (_, int index) {
                Chatroom chatroom = chatrooms[index];
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                      return UserChatPage(
                        chatroom: chatroom,
                      );
                    }));
                  },
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          chatroom.userIds.toString(),
                          // overflow: TextOverflow.ellipsis,
                        ),
                      )
                    ],
                  ),
                );
              },
              itemCount: chatrooms.length,
            ),
          ),
        ],
      ),
    );
  }

  Future getChatrooms() async {
    final result = await db
        .collection(FC.chatrooms.value)
        .where("userIds", arrayContains: currentUser!.uid)
        .get();
    debugPrint('getChatrooms: ${result.docs.length.toString()}');
    List<Chatroom> newItemList = [];
    for (var element in result.docs) {
      newItemList.add(Chatroom.fromJson({...element.data(), "id": element.id}));
    }
    setState(() {
      chatrooms = newItemList;
    });
  }

  // // subscribe to firestore
  // firestoreListenerInit() {
  //   debugPrint('Init firestore listener');
  //   firestoreListener(
  //       db, FC.chatrooms.value, chatrooms, setState, Chatroom.fromJson);
  //   setState(() {
  //     isInitFirestoreListener = true;
  //   });
  // }
}
