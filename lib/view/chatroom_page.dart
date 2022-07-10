import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat_me/firebase_utils/firestore_constant.dart';
import 'package:chat_me/firebase_utils/firestore_listener.dart';
import 'package:chat_me/model/chatroom.model.dart';
import 'package:chat_me/model/userProfile.model.dart';
import 'package:chat_me/view/user_chat_page.dart';
import 'package:flutter/material.dart';

class ChatroomPage extends StatefulWidget {
  const ChatroomPage({Key? key}) : super(key: key);

  @override
  State<ChatroomPage> createState() => _ChatroomPageState();
}

class _ChatroomPageState extends State<ChatroomPage> {
  bool isInitFirestoreListener = false;
  final db = FirebaseFirestore.instance;
  late StreamSubscription<QuerySnapshot<Map<String, dynamic>>>
      firestoreListener;
  List<Chatroom> chatrooms = [];
  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  initState() {
    initFunction();
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
        title: const Text('ChatRooms'),
      ),
      body: chatrooms.isEmpty
          ? const Center(child: Text('No Chatrooms'))
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    separatorBuilder: (BuildContext context, int index) =>
                        const Divider(
                      color: Colors.grey,
                      height: 1,
                    ),
                    itemBuilder: (_, int index) {
                      Chatroom chatroom = chatrooms[index];
                      int indexOfTargetUser =
                          chatroom.userIds.indexOf(currentUser!.uid);
                      debugPrint('indexOfTargetUser $indexOfTargetUser');
                      if (indexOfTargetUser == -1) {
                        return const SizedBox();
                      }
                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (_) {
                            return UserChatPage(
                              chatroom: chatroom,
                            );
                          }));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              CircleAvatar(
                                foregroundImage: NetworkImage(
                                  chatroom.userPhotosURLs[indexOfTargetUser],
                                ),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Text(chatroom.userNames[indexOfTargetUser]),
                              const Spacer(),
                            ],
                          ),
                        ),
                      );
                    },
                    itemCount: chatrooms.length,
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final preFetchContacts = await getContacts(null);
          if (!mounted) {
            return;
          }
          _displayContactsDialog(context, preFetchContacts,
              (UserProfile contact) async {
            final newChatroom = await createChatroom(contact);
            return newChatroom;
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _displayContactsDialog(
    BuildContext context,
    List<UserProfile> preFetchcontacts,
    Future<Chatroom?> Function(UserProfile) onCreateChatroom,
  ) async {
    return showDialog(
      context: context,
      builder: (context) {
        bool isLoading = false;
        List<UserProfile> contacts = [...preFetchcontacts];
        TextEditingController searchUsernameController =
            TextEditingController();

        return StatefulBuilder(builder: (context, setState) {
          Future _onLoadingContacts() async {
            if (mounted) {
              isLoading = true;
            }
            List<UserProfile> newContacts =
                await getContacts(searchUsernameController.text);
            setState(() {
              if (mounted) {
                contacts = newContacts;
                isLoading = false;
              }
            });
          }

          return AlertDialog(
            title: const Text('Chat with your friends'),
            content: Column(
              children: [
                // search bar

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: searchUsernameController,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          // label: Text('Search'),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        _onLoadingContacts();
                      },
                      child: const Text('Search'),
                    )
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                if (isLoading)
                  const CircularProgressIndicator()
                else
                  Expanded(
                    child: SizedBox(
                      width: double.maxFinite,
                      child: ListView.builder(
                        itemCount: contacts.length,
                        shrinkWrap: true,
                        itemBuilder: (_, int index) {
                          final UserProfile contact = contacts[index];
                          return Row(
                            children: [
                              CircleAvatar(
                                foregroundImage: NetworkImage(
                                  contact.photoURL ?? '',
                                ),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Text(contact.name),
                              const Spacer(),
                              ElevatedButton(
                                onPressed: () async {
                                  final newChatroom =
                                      await onCreateChatroom(contact);
                                  if (!mounted) {
                                    return;
                                  }
                                  if (newChatroom != null) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) {
                                          return UserChatPage(
                                              chatroom: newChatroom);
                                        },
                                      ),
                                    ).then(
                                      (value) => Navigator.of(context).pop(),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                    shape: const StadiumBorder()),
                                child: const Text('Message'),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
            actions: <Widget>[
              OutlinedButton(
                child: const Text('Cancel'),
                onPressed: () {
                  if (!mounted) return;
                  Navigator.pop(context);
                },
              ),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Add'),
              ),
              isLoading ? const CircularProgressIndicator() : const SizedBox(),
            ],
          );
        });
      },
    );
  }

  Future initFunction() async {
    await getChatrooms();
    if (!isInitFirestoreListener) {
      await firestoreListenerInit();
    }
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

  Future<Chatroom?> createChatroom(UserProfile contact) async {
    // find chatroom first
    final foundOldChatroom = await db.collection(FC.chatrooms.value).where(
        "userIds",
        arrayContains: [currentUser!.uid, contact.userId]).get();
    if (foundOldChatroom.docs.length > 1) {
      Chatroom oldChatroom = Chatroom.fromJson({
        ...foundOldChatroom.docs[0].data(),
        "id": foundOldChatroom.docs[0].id
      });
      return oldChatroom;
    }
    final myUserProfileResult =
        await db.collection(FC.userProfiles.value).doc(currentUser!.uid).get();
    if (myUserProfileResult.exists) {
      final UserProfile myUserProfile = UserProfile.fromJson(
          ({...?myUserProfileResult.data(), "id": myUserProfileResult.id}));
      final sortedUserProfiles = sortUserProfilesById(myUserProfile, contact);
      Chatroom newChatroom = Chatroom(userIds: [
        sortedUserProfiles[0].userId,
        sortedUserProfiles[1].userId
      ], userPhotosURLs: [
        sortedUserProfiles[0].photoURL ?? '',
        sortedUserProfiles[1].photoURL ?? ''
      ], userNames: [
        sortedUserProfiles[0].name,
        sortedUserProfiles[1].name,
      ]);
      String chatroomId =
          '${sortedUserProfiles[0].id}_${sortedUserProfiles[1].id}';
      newChatroom.id = chatroomId;
      await db
          .collection(FC.chatrooms.value)
          .doc(chatroomId)
          .set(newChatroom.toJson());
      return newChatroom;
    } else {
      return null;
    }
  }

  Future<List<UserProfile>> getContacts(String? userName) async {
    // var query = db.collection(FC.userProfiles.value);
    // // this is work for docId
    // // .where(FieldPath.documentId, isNotEqualTo: currentUser!.uid);
    // // .where('userId', isNotEqualTo: currentUser!.uid);
    // if (userName != null) {
    //   query
    //       .where('name', isGreaterThanOrEqualTo: userName)
    //       .where('name', isLessThanOrEqualTo: '$userName~');
    // }

    // var query = db.collection(FC.userProfiles.value);
    // if (userName != null) {
    //   debugPrint('userName $userName');
    //   String preProcessStr = userName.toLowerCase().trim();
    //   debugPrint('preProcessStr $preProcessStr');
    //   query
    //       .where('name', isGreaterThanOrEqualTo: preProcessStr)
    //       .where('name', isLessThanOrEqualTo: '$preProcessStr~');
    // }
    String preProcessStr =
        userName != null ? userName.toLowerCase().trim() : "";
    final result = await db
        .collection(FC.userProfiles.value)
        .where('nameLowerCaseNoSpace', isGreaterThanOrEqualTo: preProcessStr)
        .where('nameLowerCaseNoSpace', isLessThanOrEqualTo: '$preProcessStr~')
        .get();
    debugPrint('getContacts: ${result.docs.length.toString()}');
    List<UserProfile> newItemList = [];
    for (var element in result.docs) {
      if (element['userId'] != currentUser!.uid) {
        newItemList
            .add(UserProfile.fromJson({...element.data(), "id": element.id}));
      }
    }
    return newItemList;
  }

  // subscribe to firestore
  firestoreListenerInit() async {
    debugPrint('Init firestore listener');
    firestoreListener = await getFirestoreListener(
        db
            .collection(FC.chatrooms.value)
            .where("userIds", arrayContains: currentUser!.uid)
            .snapshots(),
        chatrooms,
        setState,
        Chatroom.fromJson);
    setState(() {
      isInitFirestoreListener = true;
    });
  }
}
