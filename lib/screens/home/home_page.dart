import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../screens/home/company_home_page.dart';
import '../../src/fcm.dart';
import '../auth/loading_page.dart';
import 'admin_home_page.dart';
import 'other_home_page.dart';

class HomePage extends StatefulWidget {
  final String userId;
  const HomePage({super.key, required this.userId});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final StreamController<List<DocumentSnapshot>> _streamController =
      StreamController<List<DocumentSnapshot>>();
  DocumentSnapshot? _userData;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _getUserData(widget.userId);
    FCMService().initialize(context);
  }

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }

  void _getUserData(String userId) {
    FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .snapshots()
        .listen((DocumentSnapshot snapshot) {
      setState(() {
        _userData = snapshot;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_userData == null) {
      return const LoadingPage();
    } else if (_userData!['user_account_type'] == 'Company') {
      return CompanyHomePage(
        userId: widget.userId,
        userData: _userData!,
      );
    } else if (_userData!['user_account_type'] == 'Editor') {
      return AdminHomePage(
        userId: widget.userId,
        userData: _userData!,
      );
    } else if (_userData!['user_account_type'] == 'Admin') {
      return AdminHomePage(
        userId: widget.userId,
        userData: _userData!,
      );
    } else {
      return OtherHomePage(
        userId: widget.userId,
        userData: _userData!,
      );
    }
  }
}
