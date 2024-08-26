import 'dart:developer';

import 'package:chat_app/screens/splash_screen.dart';
import 'package:chat_app/size_config.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_notification_channel/flutter_notification_channel.dart';
import 'package:flutter_notification_channel/notification_importance.dart';

import 'firebase_options.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])
      .then((value) {
    _initializeFirebase();
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chat App',
      theme: ThemeData(
        primaryColor: Color.fromARGB(255, 83, 168, 109),
        colorScheme:
            ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 0, 42, 49)),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Color.fromARGB(255, 83, 168, 109),
          iconTheme: IconThemeData(
            color: Color.fromARGB(255, 0, 42, 49),
          ),
          elevation: 1,
          titleTextStyle: TextStyle(
            color: Color.fromARGB(255, 0, 42, 49),
            fontWeight: FontWeight.w500,
            fontSize: 20,
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

_initializeFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  var result = await FlutterNotificationChannel.registerNotificationChannel(
    description: 'For Showing Message Notification',
    id: 'chatting',
    importance: NotificationImportance.IMPORTANCE_HIGH,
    name: 'chatting',
  );
  log(result);
}
