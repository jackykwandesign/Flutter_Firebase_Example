import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_flutter_1/auth_service.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon
            Image.network(FirebaseAuth.instance.currentUser?.photoURL ??
                'https://images.theconversation.com/files/71773/original/image-20150211-25679-rdtqd.JPG?ixlib=rb-1.1.0&q=45&auto=format&w=1200&h=1200.0&fit=crop'),
            Text(FirebaseAuth.instance.currentUser!.displayName ?? "User"),
            Text(FirebaseAuth.instance.currentUser!.email ?? "Email"),
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
