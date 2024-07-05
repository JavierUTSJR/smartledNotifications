// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Message extends StatefulWidget {
  const Message({Key? key}) : super(key: key);

  @override
  State<Message> createState() => _MessageState();
}

class _MessageState extends State<Message> {
  Map<String, dynamic> payload = {};

  @override
  Widget build(BuildContext context) {
    final dynamic data = ModalRoute.of(context)!.settings.arguments;

    // Verificar el tipo de datos recibidos
    if (data is RemoteMessage) {
      // Datos recibidos en segundo plano o terminado
      payload = data.data;
    } else if (data is Map<String, dynamic>) {
      // Datos recibidos en primer plano
      payload = data;
    } else if (data is String) {
      // Convertir datos de cadena JSON a mapa
      payload = jsonDecode(data);
    }

    // Guardar estado del LED en Firestore si existe 'isOn' en el payload
    if (payload.containsKey('isOn')) {
      _saveLedStateToFirestore(payload['isOn']);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Message"),
      ),
      body: Center(
        child: Text(payload.toString()),
      ),
    );
  }

  // Función para guardar el estado del LED en Firestore
  void _saveLedStateToFirestore(bool isOn) async {
    try {
      await FirebaseFirestore.instance.collection('led_states').add({
        'isOn': isOn,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print('Estado del LED guardado en Firestore correctamente.');
    } catch (e) {
      print('Error al guardar estado del LED en Firestore: $e');
    }
  }
}
