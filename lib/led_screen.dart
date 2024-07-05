// led_screen.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:smart_led/animaciones.dart';
import 'package:smart_led/led_notificacion';

class NormalLedScreen extends StatefulWidget {
  const NormalLedScreen({Key? key}) : super(key: key);

  @override
  _NormalLedScreenState createState() => _NormalLedScreenState();
}

class _NormalLedScreenState extends State<NormalLedScreen> {
  final String _esp8266Url = 'http://192.168.0.163';
  bool _isLedOn = false;
  late FirebaseMessaging _firebaseMessaging;

  @override
  void initState() {
    super.initState();
    _firebaseMessaging = FirebaseMessaging.instance;
    _initializeFirebaseMessaging();
    _checkNormalLedState();
  }

  Future<void> _initializeFirebaseMessaging() async {
    try {
      await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        provisional: false,
        sound: true,
      );
    } catch (e) {
      print('Error al solicitar permiso de notificación: $e');
    }
  }

  Future<void> _checkNormalLedState() async {
    try {
      final response = await http.get(Uri.parse('$_esp8266Url/normalledstate'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _isLedOn = data['isOn'];
        });
      } else {
        throw Exception('Failed to load LED state: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al cargar estado del LED: $e');
      // Puedes mostrar un diálogo o un mensaje en la UI para informar al usuario del error.
    }
  }

  Future<void> _sendNormalLedStateToEsp8266(bool isOn) async {
    final state = isOn ? 1 : 0;
    await http.get(Uri.parse('$_esp8266Url/normalled?state=$state'));
    _saveNotificationToFirestore(isOn ? 'Encendido' : 'Apagado');
  }

  Future<void> _saveNotificationToFirestore(String state) async {
    try {
      await FirebaseFirestore.instance.collection('led_notifications').add({
        'state': state,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print('Datos guardados en Firestore exitosamente.');
    } catch (e) {
      print('Error al guardar en Firestore: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80, // Aumenta la altura del AppBar
        title: const Text(
          'Foco Normal',
          style: TextStyle(color: Colors.white, fontSize: 24), // Aumenta el tamaño de la fuente
        ),
        centerTitle: false,
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          const AnimatedBackground(), // Fondo animado
          Center(
            child: Container(
              padding: const EdgeInsets.all(60), // Aumenta el padding
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.5),
                    spreadRadius: 3,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: MediaQuery.of(context).size.width * 0.4, // Aumenta el tamaño del icono
                    color: _isLedOn ? Colors.yellow : Colors.white,
                  ),
                  const SizedBox(height: 30), // Aumenta el espacio entre el icono y el texto
                  const Text(
                    'Control del Foco:',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24, // Aumenta el tamaño de la fuente
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30), // Aumenta el espacio entre el texto y el switch
                  Transform.scale(
                    scale: 2.0, // Aumenta la escala del switch
                    child: Switch(
                      value: _isLedOn,
                      onChanged: (bool newValue) {
                        setState(() {
                          _isLedOn = newValue;
                        });
                        _sendNormalLedStateToEsp8266(newValue);
                        LedNotificationHandler.sendNotification(newValue); // Llama a la función de notificación
                      },
                      activeColor: Colors.yellow,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
