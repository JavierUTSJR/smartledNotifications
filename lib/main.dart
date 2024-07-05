// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smart_led/message.dart';
import 'package:smart_led/firebase_options.dart';
import 'package:smart_led/led_screen.dart';
import 'package:smart_led/notifications.dart';

final navigatorKey = GlobalKey<NavigatorState>();

// function to listen to background changes
Future _firebaseBackgroundMessage(RemoteMessage message) async {
  if (message.notification != null) {
    print("Some notification Received in background...");
  }
}

// to handle notification on foreground on web platform
void showNotification({required String title, required String body}) {
  showDialog(
    context: navigatorKey.currentContext!,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Ok"))
      ],
    ),
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // initialize firebase messaging
  await PushNotifications.init();

  // initialize local notifications
  // dont use local notifications for web platform
  if (!kIsWeb) {
    await PushNotifications.localNotiInit();
  }

  // Listen to background notifications
  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessage);

  // on background notification tapped
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    if (message.notification != null) {
      print("Background Notification Tapped");
      navigatorKey.currentState!.pushNamed("/message", arguments: message);
    }
  });

// to handle foreground notifications
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    String payloadData = jsonEncode(message.data);
    print("Got a message in foreground");
    if (message.notification != null) {
      if (kIsWeb) {
        showNotification(
            title: message.notification!.title!,
            body: message.notification!.body!);
      } else {
        PushNotifications.showSimpleNotification(
            title: message.notification!.title!,
            body: message.notification!.body!,
            payload: payloadData);
      }
    }
  });

  // for handling in terminated state
  final RemoteMessage? message =
      await FirebaseMessaging.instance.getInitialMessage();

  if (message != null) {
    print("Launched from terminated state");
    Future.delayed(const Duration(seconds: 1), () {
      navigatorKey.currentState!.pushNamed("/message", arguments: message);
    });
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sample Flutter Firebase Notifications',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      navigatorKey: navigatorKey,
      routes: {
        "/": (context) => const NormalLedScreen(),
      },
    );
  }
}