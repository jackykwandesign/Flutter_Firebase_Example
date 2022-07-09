import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_flutter_1/view/home_page.dart';
import 'package:firebase_flutter_1/view/login_page.dart';
import 'package:firebase_flutter_1/view/new_page.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

enum AuthServiceErrorCode {
  none,
  requireEmail,
  requirePassword,
  weakPassword,
  emailAlreadyInUsed,
  userNotFound,
  wrongPassword,
  unknown,
}

class AuthServiceResult {
  UserCredential? userCredential;
  AuthServiceErrorCode code = AuthServiceErrorCode.none;

  AuthServiceResult({required this.userCredential, code});
}

class AuthService {
  // 1. handleAuthState
  handleAuthState() {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext buildContext, user) {
        if (user.hasData) {
          return AuthedPage();
        } else {
          return const LoginPage();
        }
      },
    );
  }

  // 2. signInWithGoogle
  signInWithGoogle() async {
    // Trigger the auth flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn(
      scopes: ["email"],
      signInOption: SignInOption.standard,
    ).signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;

    //Create Credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // final userCredential =
    return await FirebaseAuth.instance.signInWithCredential(credential);
    // return AuthServiceResult(userCredential: userCredential);
  }

  // 3. createUserWithEmailAndPassword
  Future<AuthServiceResult?> createUserWithEmailAndPassword(
    String emailAddress,
    String password,
  ) async {
    debugPrint('emailAddress $emailAddress');
    debugPrint('password $password');
    if (emailAddress == '') {
      return AuthServiceResult(
          userCredential: null, code: AuthServiceErrorCode.requireEmail);
    }
    if (password == '') {
      return AuthServiceResult(
          userCredential: null, code: AuthServiceErrorCode.requirePassword);
    }
    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailAddress,
        password: password,
      );
      return AuthServiceResult(userCredential: credential);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        debugPrint('The password provided is too weak.');
        return AuthServiceResult(
            userCredential: null, code: AuthServiceErrorCode.weakPassword);
      } else if (e.code == 'email-already-in-use') {
        debugPrint('The account already exists for that email.');
        return AuthServiceResult(
            userCredential: null,
            code: AuthServiceErrorCode.emailAlreadyInUsed);
      }
      return AuthServiceResult(
          userCredential: null, code: AuthServiceErrorCode.unknown);
    } catch (e) {
      return AuthServiceResult(
          userCredential: null, code: AuthServiceErrorCode.unknown);
    }
  }

  // 3. createUserWithEmailAndPassword
  Future<AuthServiceResult?> signInWithEmailAndPassword(
    String emailAddress,
    String password,
  ) async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailAddress,
        password: password,
      );
      return AuthServiceResult(userCredential: credential);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        debugPrint('No user found for that email.');
        return AuthServiceResult(
            userCredential: null, code: AuthServiceErrorCode.userNotFound);
      } else if (e.code == 'wrong-password') {
        debugPrint('Wrong password provided for that user.');
        return AuthServiceResult(
            userCredential: null, code: AuthServiceErrorCode.wrongPassword);
      }
      return AuthServiceResult(
          userCredential: null, code: AuthServiceErrorCode.unknown);
    } catch (e) {
      return AuthServiceResult(
          userCredential: null, code: AuthServiceErrorCode.unknown);
    }
  }

  // signOut
  signOut() async {
    await FirebaseAuth.instance.signOut();
    GoogleSignIn googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
  }
}
