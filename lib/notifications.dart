// ignore_for_file: unused_import, avoid_print

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PushNotifications {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Inicialización de Firebase Messaging y solicitud de permisos
  static Future<void> init() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );
  }

  // Inicialización de notificaciones locales para Android
  static Future<void> localNotiInit() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    // Solicitar permisos de notificación para Android
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );
  }

  // Función para manejar la acción al tocar una notificación en primer plano
  static Future<void> onNotificationTap(String? payload) async {
    // Aquí puedes manejar la acción al tocar la notificación en primer plano
    print('Notification Tapped with payload: $payload');
    // Ejemplo de navegación a una pantalla específica
    // navigatorKey.currentState!.pushNamed('/message', arguments: payload);
  }

  // Función para mostrar una notificación simple en Android
  static Future<void> showSimpleNotification({
    required String title,
    required String body,
    required String payload,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'your_channel_id', // ID único del canal
      'Channel Name', // Nombre del canal
      channelDescription: 'Channel Description', // Descripción del canal
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    await _flutterLocalNotificationsPlugin.show(
      0, // ID único de la notificación
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }
}
