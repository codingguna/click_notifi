import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final String backendUrl =
      "https://guna16.pythonanywhere.com/send-notification/";

  Future<void> sendTokenToBackend() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? token = await messaging.getToken();

    print("FCM Token: $token");

    if (token != null) {
      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': token}),
      );

      if (response.statusCode == 200) {
        print("✅ Notification sent: ${response.body}");
      } else {
        print("❌ Error from server: ${response.body}");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FCM Notify Test',
      home: Scaffold(
        appBar: AppBar(title: Text('FCM v1 Notify Test')),
        body: Center(
          child: ElevatedButton(
            onPressed: sendTokenToBackend,
            child: Text("Send Notification"),
          ),
        ),
      ),
    );
  }
}
