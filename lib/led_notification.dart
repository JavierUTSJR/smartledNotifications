// led_notificacion.dart

import 'package:http/http.dart' as http;
import 'dart:convert';

class LedNotificationHandler {
  static const String serverKey = 'AIzaSyBszGRUW8vj-Vq-n48lhlSm1iyJGUy6CMc'; // Tu clave de servidor de Firebase

  static Future<void> sendNotification(bool isOn) async {
    String title = isOn ? 'LED Encendido' : 'LED Apagado';
    String body = isOn ? 'El LED ha sido encendido' : 'El LED ha sido apagado';

    try {
      String token = 'YOUR_DEVICE_TOKEN'; // Reemplaza con el token de registro del dispositivo
      if (token.isEmpty) {
        throw Exception('Token de dispositivo no disponible');
      }

      final response = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverKey',
        },
        body: jsonEncode(<String, dynamic>{
          'to': token,
          'notification': <String, dynamic>{
            'title': title,
            'body': body,
          },
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'title': title,
            'body': body,
          },
        }),
      );

      if (response.statusCode == 200) {
        print('Notificación enviada correctamente.');
      } else {
        print('Error al enviar la notificación: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al enviar la notificación: $e');
    }
  }
}
