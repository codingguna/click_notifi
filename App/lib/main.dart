import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? _fcmToken = "Fetching...";
  List<String> _logs = [];
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    _initFCM();
    _initLocalNotifications();
    _listenToMessages();
  }

  void _addLog(String msg) {
    setState(() {
      _logs.insert(0, "[${DateTime.now().toLocal().toIso8601String()}] $msg");
    });
  }

  Future<void> _initFCM() async {
    _addLog("🔄 Initializing Firebase Messaging...");
    NotificationSettings settings =
        await FirebaseMessaging.instance.requestPermission();
    _addLog("🔐 Permission: ${settings.authorizationStatus}");

    String? token = await FirebaseMessaging.instance.getToken();
    setState(() {
      _fcmToken = token ?? "Token not available";
    });
    _addLog("📲 FCM Token: $_fcmToken");
  }

  void _initLocalNotifications() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    flutterLocalNotificationsPlugin.initialize(initSettings);
  }

  void _listenToMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _addLog("📨 Foreground message received: ${message.notification?.title ?? ''} - ${message.notification?.body ?? ''}");
      _showLocalNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _addLog("📱 Message opened from background");
    });
  }

  void _showLocalNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'fcm_default_channel',
      'FCM Notifications',
      channelDescription: 'Channel for showing FCM messages',
      importance: Importance.max,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      message.notification?.title ?? "No title",
      message.notification?.body ?? "No message",
      notificationDetails,
    );
  }

  Future<void> _sendNotification() async {
    if (_fcmToken == null || _fcmToken == "Token not available") {
      _addLog("❌ No FCM token to send notification");
      return;
    }

    const serverUrl = "https://guna16.pythonanywhere.com/send-notification/";

    try {
      _addLog("📤 Sending request to server...");
      var response = await http.post(
        Uri.parse(serverUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"token": _fcmToken}),
      );

      if (response.statusCode == 200) {
        _addLog("✅ Notification sent successfully");
      } else {
        _addLog("❌ Server Error ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      _addLog("⚠️ Request failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FCM Logger App',
      home: Scaffold(
        appBar: AppBar(title: Text("FCM Test App")),
        body:Scrollbar(child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Text("📲 Your FCM Token:", style: TextStyle(fontWeight: FontWeight.bold)),
              SelectableText(_fcmToken ?? "null", style: TextStyle(fontSize: 12)),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _sendNotification,
                child: Text("Send Notification"),
              ),
              SizedBox(height: 10),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListView(
                    reverse: true,
                    children: _logs
                        .map((log) => Text(log, style: TextStyle(fontSize: 12)))
                        .toList(),
                  ),
                ),
              )
            ],
          ),
        ),
      ),),
    );
  }
}
