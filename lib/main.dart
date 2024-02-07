import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'screens/auth/auth_error_page.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/verify_email_page.dart';
import 'screens/home/home_page.dart';
import 'src/local_notification_service.dart';
import 'src/theme.dart';

Future<void> backgroundHandler(RemoteMessage message) async {
  // print('message from background');
}

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(backgroundHandler);
  LocalNotificationService().initialize();
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) => runApp(const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TudoPr',
      theme: TAppTheme.lightTheme,
      darkTheme: TAppTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: const AuthenticationWrapper(),
    );
  }
}

class AuthenticationWrapper extends StatefulWidget {
  const AuthenticationWrapper({Key? key}) : super(key: key);

  @override
  State<AuthenticationWrapper> createState() => _AuthenticationWrapperState();
}

class _AuthenticationWrapperState extends State<AuthenticationWrapper> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final userRef = FirebaseFirestore.instance.collection('Users');
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  String authState = '';
  String userId = '';

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<bool> doesUserExist(String userId) async {
    final userRef = FirebaseFirestore.instance.collection('Users').doc(userId);
    final userDoc = await userRef.get();
    return userDoc.exists;
  }

  void _checkAuthStatus() async {
    User? user = _auth.currentUser;

    if (user == null) {
      setState(() {
        authState = 'unAuthenticated';
      });
    } else {
      bool userExists = await doesUserExist(user.uid);

      if (userExists) {
        ///update device token
        messaging.getToken().then((token) {
          userRef.doc(user.uid).update({
            'user_device_token': token,
            'user_last_interaction': FieldValue.serverTimestamp(),
          });
        });
        setState(() {
          authState = 'ProfileCompleted';
          userId = user.uid;
        });
      } else {
        setState(() {
          authState = 'NoDataAvailable';
          userId = user.uid;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (authState != '') {
      FlutterNativeSplash.remove();
    }
    switch (authState) {
      case 'unAuthenticated':
        return const LoginScreen();
      case 'ProfileCompleted':
        return HomePage(userId: userId);
      case 'NoDataAvailable':
        return VerifyEmailPage(userId: userId);
      default:
        return const AuthErrorPage();
    }
  }
}
