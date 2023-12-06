import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:wechat/api/apis.dart';
import 'package:wechat/main.dart';
import 'package:wechat/screens/auth/login_screen.dart';
import 'package:wechat/screens/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.step});

  final String step;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: widget.step == 'step1' ? 2 : 1), () {
      if (widget.step == "step1")
        Step1();
      else
        Step2();
    });
  }

  void Step1() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.white, statusBarColor: Colors.white));

    if (APIs.auth.currentUser != null) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    } else {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  void Step2() async {
    await APIs.updateActiveStatus(false, true);

    //sign out from app
    await APIs.auth.signOut().then((value) async {
      // firebase auth dan çıkış yapıldı.
      await GoogleSignIn().signOut().then((value) {
        // google dan çıkış yapıldı
        APIs.auth = FirebaseAuth.instance;
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;

    return Scaffold(
        body: Stack(
      // app logo
      children: [
        Positioned(
            top: mq.height * .15,
            right: mq.width * .25,
            width: mq.width * .5,
            child: Image.asset("images/icon.png")),

        // google login button
        Positioned(
          bottom: mq.height * .15,
          width: mq.width,
          child: const Text(
            "mustafawiped tarafından geliştirildi. 💜",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 16, color: Colors.black87, letterSpacing: .5),
          ),
        ),
      ],
    ));
  }
}
