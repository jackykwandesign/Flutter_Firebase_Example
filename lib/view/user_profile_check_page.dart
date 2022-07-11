import 'package:chat_me/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat_me/firebase_utils/firestore_constant.dart';
import 'package:chat_me/model/userProfile.model.dart';
import 'package:chat_me/view/authed_page_container.dart';
import 'package:flutter/material.dart';

class UserProfileCheckPage extends StatefulWidget {
  UserProfileCheckPage({Key? key}) : super(key: key);

  @override
  State<UserProfileCheckPage> createState() => _UserProfileCheckPageState();
}

class _UserProfileCheckPageState extends State<UserProfileCheckPage> {
  final currentUser = FirebaseAuth.instance.currentUser;
  final db = FirebaseFirestore.instance;
  late CollectionReference<Map<String, dynamic>> userProfileCollection;
  late TextEditingController nickNameController;
  bool isLoading = true;
  bool isPassUserProfileCheck = false;
  late UserProfile userProfile;

  @override
  void initState() {
    nickNameController =
        TextEditingController(text: currentUser?.displayName ?? "new user");
    userProfileCollection = db.collection(FC.userProfiles.value);
    checkUserProfile();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (isPassUserProfileCheck) {
      return const AuthedPageContainer();
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            if (isLoading)
              Center(
                child: Column(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        AuthService().signOut();
                      },
                      child: const Text('Signout'),
                    )
                  ],
                ),
              )
            else
              const SizedBox(),
            if (!isLoading)
              Column(
                children: [
                  const Text(
                    'Please complete your personal infomation',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextField(
                    controller: nickNameController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      label: Text('Nickname'),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await upsertUserProfile();
                      await checkUserProfile();
                    },
                    child: const Text('Confirm'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      AuthService().signOut();
                    },
                    child: const Text('Signout'),
                  )
                ],
              )
            else
              const SizedBox(),
          ],
        ),
      ),
    );
  }

  Future checkUserProfile() async {
    setState(() {
      isLoading = true;
    });
    final result = await userProfileCollection.doc(currentUser!.uid).get();
    debugPrint('checkAndCreateUserProfile');
    debugPrint(result.data().toString());
    debugPrint('userprofile exist = ${result.exists}');
    if (result.exists) {
      setState(() {
        userProfile =
            UserProfile.fromJson({...?result.data(), "id": result.id});
        isPassUserProfileCheck = true;
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  Future upsertUserProfile() async {
    UserProfile newUserProfile = UserProfile(
      name: nickNameController.text,
      nameLowerCaseNoSpace: nickNameController.text.toLowerCase().trim(),
      photoURL: currentUser?.photoURL,
      userId: currentUser!.uid,
    );
    final createUserProfileResult = await userProfileCollection
        .doc(currentUser!.uid)
        .set(newUserProfile.toJson());
  }
}
