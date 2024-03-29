import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:tudopr/screens/journalist/journalist_profile_page.dart';

import '../../screens/company/company_subscription_page.dart';
import '../../src/helper_widgets.dart';
import '../../src/theme.dart';
import '../company/company_news_page.dart';
import '../company/company_notification_page.dart';
import '../company/company_profile_page.dart';
import '../company/company_support_page.dart';
import '../journalist/journalist_home_view.dart';

class OtherHomePage extends StatefulWidget {
  final String userId;
  final DocumentSnapshot userData;
  const OtherHomePage(
      {super.key, required this.userId, required this.userData});

  @override
  State<OtherHomePage> createState() => _OtherHomePageState();
}

class _OtherHomePageState extends State<OtherHomePage> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  var _currentIndex = 0;
  DocumentSnapshot? _userData;
  String language = '';

  @override
  void initState() {
    super.initState();
    setState(() {
      _userData = widget.userData;
      language = widget.userData['user_language'];
    });
    _getUserData(widget.userId);
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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          popupMenuTheme: PopupMenuThemeData(
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(10), // Adjust this value as needed
            ),
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: TAppTheme.primaryColor,
            elevation: 8,
            title: const Row(
              children: [
                Image(
                  height: 18,
                  fit: BoxFit.cover,
                  image: AssetImage(
                    'assets/images/nav_logo.png',
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              _notificationMessage((widget.userData['user_notification_count']),
                  widget.userData),
              PopupMenuButton<String>(
                onSelected: (String result) {
                  if (result == '0') {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (_) => JournalistProfilePage(
                          userId: widget.userId,
                          userData: _userData!,
                        ),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (_) => CompanySubscriptionPage(
                          userId: widget.userId,
                          userData: _userData!,
                        ),
                      ),
                    );
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: '0',
                    child: Row(
                      children: [
                        const Icon(
                          CupertinoIcons.person_alt_circle_fill,
                          color: Colors.black87,
                          size: 20,
                        ),
                        addHorizontalSpace(10),
                        blackBoldTextWithSize(
                            language == 'ro' ? 'Profil' : 'Profile', 16),
                      ],
                    ),
                    // ),
                    // PopupMenuItem<String>(
                    //   value: '1',
                    //   child: Row(
                    //     children: [
                    //       const Icon(
                    //         CupertinoIcons.creditcard_fill,
                    //         color: Colors.black87,
                    //         size: 20,
                    //       ),
                    //       addHorizontalSpace(10),
                    //       blackBoldTextWithSize(
                    //           language == 'ro' ? 'Abonament' : 'Subscription',
                    //           16),
                    //     ],
                    //   ),
                  ),
                ],
              ),
            ],
          ),
          body: decider(),
          bottomNavigationBar: SalomonBottomBar(
            currentIndex: _currentIndex,
            onTap: (i) => setState(() => _currentIndex = i),
            items: [
              /// Home
              SalomonBottomBarItem(
                icon: Image(
                  image: const AssetImage('assets/icons/home-dark.png'),
                  height: 20,
                  width: 20,
                  color: _currentIndex == 0 ? Colors.teal : Colors.black,
                ),
                title: Text(
                  widget.userData['user_language'] == 'ro' ? 'Acasă' : 'Home',
                  style: GoogleFonts.quicksand(
                    textStyle: const TextStyle(
                      fontSize: 14.0,
                      letterSpacing: .5,
                    ),
                  ),
                ),
                selectedColor: Colors.teal,
              ),

              /// Likes
              SalomonBottomBarItem(
                icon: Image(
                  image: const AssetImage('assets/icons/from_dark.png'),
                  height: 20,
                  width: 20,
                  color: _currentIndex == 1 ? Colors.teal : Colors.black,
                ),
                title: Text(
                  widget.userData['user_language'] == 'ro' ? 'Știri' : 'News',
                  style: GoogleFonts.quicksand(
                    textStyle: const TextStyle(
                      fontSize: 14.0,
                      letterSpacing: .5,
                    ),
                  ),
                ),
                selectedColor: Colors.teal,
              ),

              /// Profile
              SalomonBottomBarItem(
                icon: Image(
                  image: const AssetImage('assets/icons/chat.png'),
                  height: 20,
                  width: 20,
                  color: _currentIndex == 4 ? Colors.teal : Colors.black,
                ),
                title: Text(
                  widget.userData['user_language'] == 'ro'
                      ? 'Suport'
                      : 'Support',
                  style: GoogleFonts.quicksand(
                    textStyle: const TextStyle(
                      fontSize: 14.0,
                      letterSpacing: .5,
                    ),
                  ),
                ),
                selectedColor: Colors.teal,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget decider() {
    if (_currentIndex == 0) {
      return JournalistHomeView(
        userId: widget.userId,
        userData: widget.userData,
      );
    } else if (_currentIndex == 1) {
      return CompanyNewsPage(
        userId: widget.userId,
        userData: widget.userData,
      );
    } else if (_currentIndex == 2) {
      return CompanySupportPage(
        userId: widget.userId,
        userData: widget.userData,
      );
    } else {
      return Container(
        color: Colors.black26,
      );
    }
  }

  Widget _notificationMessage(int count, DocumentSnapshot myRealtimeInfo) {
    if (count > 0) {
      return Center(
        child: Stack(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: IconButton(
                  icon: const Icon(
                    CupertinoIcons.bell,
                    size: 24,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (_) => CompanyNotificationsPage(
                          userId: widget.userId,
                          myUserInfo: myRealtimeInfo,
                        ),
                      ),
                    );
                  }),
            ),
            Positioned(
              right: 9,
              top: 6,
              child: Container(
                height: 14,
                width: 14,
                padding: const EdgeInsets.all(0),
                decoration: BoxDecoration(
                  color: const Color(0xfffd1d1d),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Center(
                  child: Text(
                    count > 9 ? '9+' : count.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 7,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: IconButton(
          icon: const Icon(
            CupertinoIcons.bell,
            size: 24,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (_) => CompanyNotificationsPage(
                  userId: widget.userId,
                  myUserInfo: myRealtimeInfo,
                ),
              ),
            );
          },
        ),
      );
    }
  }
}
