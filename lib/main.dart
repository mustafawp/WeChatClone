import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_notification_channel/flutter_notification_channel.dart';
import 'package:flutter_notification_channel/notification_importance.dart';
import 'package:wechat/screens/home_screen.dart';
import 'package:wechat/screens/splash_screen.dart';
import 'firebase_options.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

// cihaz ekran boyutuna erişmek için global nesne
late Size mq;

void main() async {
  // widgets ensure initalize
  WidgetsFlutterBinding.ensureInitialized();

  // ui mode
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])
      .then((value) async {
    // firebase initalize
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);

    // notification channel
    await FlutterNotificationChannel.registerNotificationChannel(
      description: 'Mesaj bildirimlerini buradan kapatıp açabilirsin.',
      id: 'chats',
      importance: NotificationImportance.IMPORTANCE_HIGH,
      name: 'Chats',
    );

    // app check
    await FirebaseAppCheck.instance.activate();

    // run app
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'We Chat!',
      theme: ThemeData(
          appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.black),
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.normal,
          fontSize: 19,
        ),
        backgroundColor: Colors.white,
      )),
      routes: {
        '/home': (context) => HomeScreen(),
      },
      home: const SplashScreen(),
      //home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}
