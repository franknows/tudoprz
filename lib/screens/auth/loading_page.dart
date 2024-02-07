import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'login_screen.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  String oldPassword = '';
  String newPassword = '';

  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
  }

  Future<void> logOutUser() async {
    try {
      await auth.signOut();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        CupertinoPageRoute(builder: (context) => const LoginScreen()),
        (r) => false,
      );
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.white,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Icon(
            CupertinoIcons.hourglass,
            size: 48,
            color: Colors.grey.withOpacity(.4),
          ),
        ),
      ),
    );
  }
}
