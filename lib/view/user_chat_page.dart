import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_flutter_1/firebase_utils/firestore_constant.dart';
import 'package:firebase_flutter_1/firebase_utils/firestore_listener.dart';
import 'package:firebase_flutter_1/model/chatMessage.model.dart';
import 'package:firebase_flutter_1/model/chatroom.model.dart';
import 'package:flutter/material.dart';

class UserChatPage extends StatefulWidget {
  final Chatroom chatroom;
  const UserChatPage({Key? key, required this.chatroom}) : super(key: key);

  @override
  State<UserChatPage> createState() => _UserChatPageState();
}

class _UserChatPageState extends State<UserChatPage> {
  final currentUser = FirebaseAuth.instance.currentUser;
  bool isInitFirestoreListener = false;
  final db = FirebaseFirestore.instance;
  late CollectionReference<Map<String, dynamic>> chatMessageCollection;
  late StreamSubscription<QuerySnapshot<Map<String, dynamic>>>
      firestoreListener;
  List<ChatMessage> chatMessages = [];
  late TextEditingController inputMessageController;

  @override
  void initState() {
    chatMessageCollection = db
        .collection(FC.chatrooms.value)
        .doc(widget.chatroom.id)
        .collection(FC.chatMessages.value);

    inputMessageController = TextEditingController();
    getChatMessage();
    if (!isInitFirestoreListener) {
      firestoreListenerInit();
    }
    super.initState();
  }

  @override
  void dispose() {
    firestoreListener.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chatroom.id),
      ),
      body: Column(
        children: [
          // Chat records
          Expanded(
            child: ListView.builder(
              itemCount: chatMessages.length,
              itemBuilder: (_, int index) {
                ChatMessage chatMessage = chatMessages[index];
                bool isFromCurrentUser =
                    chatMessage.sendByUserId == currentUser!.uid;
                return Container(
                  margin: const EdgeInsets.all(2),
                  child: Row(
                    mainAxisAlignment: isFromCurrentUser
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onLongPress: () => _displayDeleteChatMessageDialog(
                            context, chatMessage),
                        child: Container(
                          constraints: BoxConstraints(
                            minWidth: 100,
                            maxWidth: MediaQuery.of(context).size.width * 0.7,
                          ),
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color:
                                isFromCurrentUser ? Colors.green : Colors.grey,
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          child: Text(
                            chatMessage.message,
                            style: const TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // input field
          Row(
            children: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.add)),
              Expanded(
                child: TextField(
                  controller: inputMessageController,
                  decoration:
                      const InputDecoration(hintText: "Type something..."),
                ),
              ),
              IconButton(
                  onPressed: () => sendMessage(), icon: const Icon(Icons.send)),
            ],
          )
        ],
      ),
    );
  }

  Future<void> _displayDeleteChatMessageDialog(
      BuildContext context, ChatMessage chatMessage) async {
    return showDialog(
      context: context,
      builder: (context) {
        bool isLoading = false;
        return StatefulBuilder(builder: (context, setState) {
          Future onSubmit() async {
            setState(() {
              isLoading = true;
            });
            await deleteChatMessage(chatMessage.id);
            if (!mounted) {
              return;
            }
            setState(() {
              isLoading = false;
            });
            Navigator.pop(context);
          }

          return AlertDialog(
            title:
                Text('Do you want to delete message: ${chatMessage.message} ?'),
            actions: <Widget>[
              OutlinedButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(primary: Colors.red),
                onPressed: isLoading ? null : onSubmit,
                child: const Text('Delete'),
              ),
              isLoading ? const CircularProgressIndicator() : const SizedBox(),
            ],
          );
        });
      },
    );
  }

  Future getChatMessage() async {
    final result = await chatMessageCollection
        .orderBy("createAt", descending: false)
        .get();
    debugPrint('getChatMessages: ${result.docs.length.toString()}');
    List<ChatMessage> newItemList = [];
    for (var element in result.docs) {
      newItemList
          .add(ChatMessage.fromJson({...element.data(), "id": element.id}));
    }
    setState(() {
      chatMessages = newItemList;
    });
  }

  Future createChatMessage(ChatMessage chatMessage) async {
    await chatMessageCollection.add(chatMessage.toJson());
  }

  Future updateChatMessage(String id, ChatMessage newItem) async {
    await chatMessageCollection.doc(id).update(newItem.toJson());
  }

  Future deleteChatMessage(String id) async {
    await chatMessageCollection.doc(id).delete();
  }

  Future sendMessage() async {
    ChatMessage chatMessage = ChatMessage(
      message: inputMessageController.text,
      sendByUserId: currentUser!.uid,
      chatroomId: widget.chatroom.id,
    );
    await createChatMessage(chatMessage);
    debugPrint(
        'Send Message to chatroom ${chatMessage.chatroomId}, message = ${chatMessage.message}');
    // clear inputMessage
    inputMessageController.clear();
  }

  // subscribe to firestore
  Future firestoreListenerInit() async {
    debugPrint('Init firestore listener');
    // firestoreListener = await getFirestoreListener(
    //   chatMessageCollection.orderBy("createAt", descending: false).snapshots(),
    //   chatMessages,
    //   setState,
    //   ChatMessage.fromJson,
    // );

    firestoreListener = chatMessageCollection
        .orderBy("createAt", descending: false)
        .snapshots()
        .listen(
      (event) {
        for (var change in event.docChanges) {
          switch (change.type) {
            case DocumentChangeType.added:
              int foundIndex = chatMessages
                  .indexWhere((element) => element.id == change.doc.id);
              if (foundIndex == -1) {
                debugPrint('NEW ITEM: old length ${chatMessages.length}');
                setState(() {
                  chatMessages.add(ChatMessage.fromJson(
                      {...?change.doc.data(), "id": change.doc.id}));
                });
                debugPrint('NEW ITEM: new length ${chatMessages.length}');
                debugPrint(
                    "New ${chatMessages.runtimeType} Item: ${change.doc.data()}");
              }

              break;
            case DocumentChangeType.modified:
              int foundIndex = chatMessages
                  .indexWhere((element) => element.id == change.doc.id);
              if (foundIndex != -1) {
                setState(() {
                  chatMessages[foundIndex] = ChatMessage.fromJson(
                      {...?change.doc.data(), "id": change.doc.id});
                });
                debugPrint(
                    "Modified ${chatMessages.runtimeType}: ${change.doc.data()}");
              }

              break;
            case DocumentChangeType.removed:
              int foundIndex = chatMessages
                  .indexWhere((element) => element.id == change.doc.id);
              if (foundIndex != -1) {
                setState(() {
                  chatMessages.removeAt(foundIndex);
                });
                debugPrint(
                    "Removed ${chatMessages.runtimeType}: ${change.doc.data()}");
              }

              break;
          }
        }
      },
    );
    // chatMessageCollection
    //     .orderBy("createAt", descending: false)
    //     .snapshots()
    //     .listen(
    //   (event) {
    //     for (var change in event.docChanges) {
    //       switch (change.type) {
    //         case DocumentChangeType.added:
    //           int foundIndex = chatMessages
    //               .indexWhere((element) => element.id == change.doc.id);
    //           if (foundIndex == -1) {
    //             setState(() {
    //               chatMessages.add(ChatMessage.fromJson(
    //                   {...?change.doc.data(), "id": change.doc.id}));
    //             });
    //             debugPrint(
    //                 "New ${chatMessages.runtimeType} Item: ${change.doc.data()}");
    //           }

    //           break;
    //         case DocumentChangeType.modified:
    //           int foundIndex = chatMessages
    //               .indexWhere((element) => element.id == change.doc.id);
    //           if (foundIndex != -1) {
    //             setState(() {
    //               chatMessages[foundIndex] = ChatMessage.fromJson(
    //                   {...?change.doc.data(), "id": change.doc.id});
    //             });
    //             debugPrint(
    //                 "Modified ${chatMessages.runtimeType}: ${change.doc.data()}");
    //           }

    //           break;
    //         case DocumentChangeType.removed:
    //           int foundIndex = chatMessages
    //               .indexWhere((element) => element.id == change.doc.id);
    //           if (foundIndex != -1) {
    //             setState(() {
    //               chatMessages.removeAt(foundIndex);
    //             });
    //             debugPrint(
    //                 "Removed ${chatMessages.runtimeType}: ${change.doc.data()}");
    //           }

    //           break;
    //       }
    //     }
    //   },
    // );

    setState(() {
      isInitFirestoreListener = true;
    });
  }
}
