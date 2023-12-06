import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:wechat/api/apis.dart';
import 'package:wechat/helper/dialogs.dart';
import 'package:wechat/main.dart';
import 'package:wechat/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isAnimate = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isAnimate = true;
      });
    });
  }

  void _handleGoogleBtnClick() {
    Dialogs.showProgressbar(context);
    signInWithGoogle().then((user) async {
      Navigator.pop(context);
      if (user != null) {
        if (await APIs.userExists()) {
          // ignore: use_build_context_synchronously
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const HomeScreen()));
        } else {
          APIs.createUser().then((value) => {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()))
              });
        }
      } else {}
    });
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      await InternetAddress.lookup("google.com");
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await APIs.auth.signInWithCredential(credential);
    } catch (e) {
      print("\n ERROR _signInWithGoogle: $e");
      // ignore: use_build_context_synchronously
      Dialogs.showSnackBar(context, "Something went wrong (Check Internet)");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;

    return Scaffold(
        // app bar
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text("Welcome to We Chat"),
        ),
        body: Stack(
          // app logo
          children: [
            AnimatedPositioned(
                top: mq.height * .15,
                right: _isAnimate ? mq.width * .25 : -mq.width * .5,
                width: mq.width * .5,
                duration: const Duration(seconds: 1),
                child: Image.asset("images/icon.png")),

            // google login button
            Positioned(
              bottom: mq.height * .15,
              left: mq.width * .05,
              width: mq.width * .9,
              height: mq.height * 0.07,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 223, 255, 187),
                    shape: const StadiumBorder(),
                    elevation: 1),
                onPressed: () {
                  _handleGoogleBtnClick();
                },
                icon: Image.asset(
                  "images/google.png",
                  height: mq.height * 0.04,
                ),
                label: RichText(
                    text: const TextSpan(
                  style: TextStyle(color: Colors.black, fontSize: 17),
                  children: [
                    TextSpan(text: "Sign In with "),
                    TextSpan(
                      text: "Google",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                )),
              ),
            ),
          ],
        ));
  }
}
