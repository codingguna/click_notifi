# 🔔 Flutter FCM Notification App with Django Backend

A simple Flutter app that sends push notifications using Firebase Cloud Messaging (FCM) via a Django backend.

---

## 📱 Flutter App

- Gets and shows FCM token
- Requests notification permission
- Logs all activity (token, request, response)
- Shows notification in foreground using `flutter_local_notifications`
- Sends request to Django backend on button press

---

## 🌐 Django Backend

- Accepts FCM token via `/send-notification/`
- Uses Firebase Admin SDK with `serviceAccountKey.json`
- Sends push notification using FCM v1 API

---

## 🔧 Setup

### Firebase:
- Create Firebase project
- Add Android app
- Download `google-services.json` → place in `android/app/`
- Enable **FCM API (v1)** in Google Cloud Console
- Create and download `serviceAccountKey.json` for backend

---

### Flutter:
- Add these packages:
```yaml
firebase_core
firebase_messaging
flutter_local_notifications
http
```
- Add Internet and POST_NOTIFICATIONS permissions
- Use `getToken()` to get FCM token
- Send it to your backend

---

### Django:
- Install firebase-admin
- Load `serviceAccountKey.json`
- Handle /send-notification/ endpoint
- Add your domain to ALLOWED_HOSTS

---

## 🚀 Demo
- Run Django server (e.g., PythonAnywhere)
- Run Flutter app on a device
- Click "Send Notification" → You’ll see a local notification

---

## 📌 Notes
- Token changes after reinstall – always send updated token
- Foreground messages use flutter_local_notifications
- Backend uses FCM v1 with service account

---

Made with ❤️ using Flutter, Firebase, and Django.
 
---
