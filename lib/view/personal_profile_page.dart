import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat_me/auth_service.dart';
import 'package:flutter/material.dart';

class PersonalProfileTab extends StatelessWidget {
  PersonalProfileTab({Key? key}) : super(key: key);
  final currentUser = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon
            CircleAvatar(
              foregroundImage: NetworkImage(
                currentUser?.photoURL ?? '',
                scale: 5.0,
              ),
              backgroundImage: const AssetImage('assets/images/user_icon.jpg'),
            ),
            Text(currentUser?.displayName ?? "User"),
            Text(currentUser!.email ?? "Email"),
            ElevatedButton(
              onPressed: () {
                AuthService().signOut();
              },
              child: const Text('SignOut'),
            )
          ],
        ),
      ),
    );
  }
}
