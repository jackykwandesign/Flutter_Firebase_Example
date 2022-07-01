import 'package:firebase_flutter_1/auth_service.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  var authServiceError = AuthServiceErrorCode.none;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: 'Email',
                border: OutlineInputBorder(),
              ),
              controller: emailController,
            ),
            const SizedBox(
              height: 15,
            ),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Password',
                border: OutlineInputBorder(),
              ),
              controller: passwordController,
            ),
            authServiceError != AuthServiceErrorCode.none
                ? Text(authServiceError.toString())
                : Container(),
            ElevatedButton(
              onPressed: () async {
                final result =
                    await AuthService().createUserWithEmailAndPassword(
                  emailController.text,
                  passwordController.text,
                );
                debugPrint(result?.code.toString());
                if (result?.code != AuthServiceErrorCode.none) {
                  setState(() {
                    authServiceError = result?.code as AuthServiceErrorCode;
                  });
                }
              },
              child: const Text('Register'),
            ),
            ElevatedButton(
              onPressed: () async {
                final result = await AuthService().signInWithEmailAndPassword(
                  emailController.value.toString(),
                  passwordController.value.toString(),
                );
                if (result?.code != AuthServiceErrorCode.none) {
                  setState(() {
                    authServiceError = result?.code as AuthServiceErrorCode;
                  });
                }
              },
              child: const Text('SignIn'),
            ),
            ElevatedButton(
              onPressed: () {
                AuthService().signInWithGoogle();
              },
              child: const Text('Google Signin'),
            ),
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
