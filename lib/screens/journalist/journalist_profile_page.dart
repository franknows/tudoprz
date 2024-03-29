import 'package:awesome_circular_chart/awesome_circular_chart.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../src/helper_widgets.dart';
import '../../src/theme.dart';
import '../auth/login_screen.dart';

class JournalistProfilePage extends StatefulWidget {
  final String userId;
  final DocumentSnapshot userData;
  const JournalistProfilePage(
      {super.key, required this.userId, required this.userData});

  @override
  State<JournalistProfilePage> createState() => _JournalistProfilePageState();
}

class _JournalistProfilePageState extends State<JournalistProfilePage> {
  String language = '';
  DocumentSnapshot? _userData;
  final GlobalKey<AnimatedCircularChartState> _chartKey =
      GlobalKey<AnimatedCircularChartState>();
  int total = 0;
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getTotal();
    setState(() {
      _userData = widget.userData;
    });
    _getUserData(widget.userId);
    setState(() {
      language = widget.userData['user_language'];
    });
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

  getTotal() {
    // setState(() {
    //   total = widget.userData['press_left_count'] +
    //       widget.userData['interview_left_count'] +
    //       widget.userData['interview_left_count'] +
    //       20;user_categories
    // });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.white,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: TAppTheme.primaryColor,
            elevation: 4,
            title: Text(
              language == 'ro' ? 'Profil' : 'Profile',
              style: GoogleFonts.quicksand(
                textStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                  letterSpacing: .5,
                ),
              ),
            ),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          body: SingleChildScrollView(
            child: Container(
              color: Colors.blueGrey.withOpacity(0.1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(bottom: 100.0),
                        child: Image(
                          width: double.infinity,
                          image: AssetImage('assets/images/profile_bg.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: size.width / 2.4,
                        left: 20,
                        right: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    // getImage();
                                  },
                                  child: CircleAvatar(
                                    radius: 58,
                                    backgroundColor: Colors.white,
                                    child: Padding(
                                      padding: const EdgeInsets.all(3.0),
                                      child: ClipOval(
                                        // Wrap with ClipOval to make the image circular
                                        child: CachedNetworkImage(
                                          imageUrl:
                                              widget.userData['user_image'],
                                          placeholder: (context, url) =>
                                              Image.asset(
                                            'assets/images/vertical_placeholder.png',
                                            fit: BoxFit.cover,
                                            width: 90,
                                            height: 90,
                                          ),
                                          errorWidget: (context, url, error) =>
                                              Image.asset(
                                            'assets/images/vertical_placeholder.png',
                                            fit: BoxFit.cover,
                                            width: 90,
                                            height: 90,
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    // Navigator.push(
                                    //   context,
                                    //   CupertinoPageRoute(
                                    //     builder: (_) => AdminUpdateProfile(
                                    //       userId: widget.userId,
                                    //       userData: widget.userData,
                                    //     ),
                                    //   ),
                                    // );
                                  },
                                  child: CircleAvatar(
                                    radius: 24,
                                    backgroundColor:
                                        TAppTheme.primaryColor.withOpacity(.4),
                                    child: const CircleAvatar(
                                      radius: 20,
                                      backgroundColor: TAppTheme.primaryColor,
                                      child: Icon(
                                        CupertinoIcons.pencil,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            addVerticalSpace(10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                blackBoldTextWithSize(
                                    widget.userData['user_name'], 18),
                                addVerticalSpace(6.0),
                                blackBioText(widget.userData['about_user'])
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                          bottomRight: Radius.circular(10),
                          bottomLeft: Radius.circular(10)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 6,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          addVerticalSpace(20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                children: [
                                  blackBoldText('0'),
                                  language == 'ro'
                                      ? blackNormalCenteredText(
                                          'Comunicate\nde presă')
                                      : blackNormalCenteredText(
                                          'Press\nreleases'),
                                ],
                              ),
                              Container(
                                height: 20,
                                width: 1,
                                color: Colors.grey,
                              ),
                              Column(
                                children: [
                                  blackBoldText('0'),
                                  language == 'ro'
                                      ? blackNormalCenteredText('Interviuri')
                                      : blackNormalCenteredText('Interviews'),
                                ],
                              ),
                              Container(
                                height: 20,
                                width: 1,
                                color: Colors.grey,
                              ),
                              Column(
                                children: [
                                  blackBoldText('0'),
                                  language == 'ro'
                                      ? blackNormalCenteredText(
                                          'Evenimente\nde presă')
                                      : blackNormalCenteredText('Press events'),
                                ],
                              ),
                            ],
                          ),
                          addVerticalSpace(20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 5.0,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                          bottomRight: Radius.circular(10),
                          bottomLeft: Radius.circular(10)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 6,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          addVerticalSpace(20),
                          profileTiles(
                            language == 'ro'
                                ? 'Limba (${widget.userData['user_language']})'
                                : 'Language (${widget.userData['user_language']})',
                            language == 'ro'
                                ? 'Atingeți pentru a schimba limba'
                                : 'Tap to change the language',
                          ),
                          const SizedBox(
                            height: 6.0,
                          ),
                          Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: InkWell(
                                  onTap: () {
                                    ///start of user update
                                    DocumentReference ds = FirebaseFirestore
                                        .instance
                                        .collection('Users')
                                        .doc(widget.userId);
                                    Map<String, dynamic> updateTasks = {
                                      'user_language': 'ro',
                                    };
                                    ds.update(updateTasks);
                                  },
                                  child:
                                      swToggleBox(_userData!['user_language']),
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                flex: 1,
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      ///start of user update
                                      DocumentReference ds = FirebaseFirestore
                                          .instance
                                          .collection('Users')
                                          .doc(widget.userId);
                                      Map<String, dynamic> updateTasks = {
                                        'user_language': 'eng',
                                      };
                                      ds.update(updateTasks);
                                    });
                                  },
                                  child:
                                      engToggleBox(_userData!['user_language']),
                                ),
                              ),
                            ],
                          ),
                          addVerticalSpace(4.0),
                          Divider(
                            color: Colors.grey.withOpacity(.4),
                          ),
                          addVerticalSpace(2.0),
                          Row(
                            children: [
                              black54BoldText(
                                language == 'ro'
                                    ? 'Abonament: ${widget.userData['user_plan'] == '-' ? 'DEMO' : widget.userData['user_plan']}'
                                    : 'Subscription: ${widget.userData['user_plan'] == '-' ? 'DEMO' : widget.userData['user_plan']}',
                              ),
                            ],
                          ),
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //   children: [
                          //     AnimatedCircularChart(
                          //       holeRadius: 30,
                          //       key: _chartKey,
                          //       size: Size(120, 120),
                          //       initialChartData: <CircularStackEntry>[
                          //         CircularStackEntry(
                          //           <CircularSegmentEntry>[
                          //             CircularSegmentEntry(
                          //               (widget.userData[
                          //                           'interview_left_count'] /
                          //                       total) *
                          //                   100,
                          //               Colors.blue[400],
                          //               rankKey: 'completed',
                          //             ),
                          //             CircularSegmentEntry(
                          //               (widget.userData['event_left_count'] /
                          //                       total) *
                          //                   100,
                          //               Colors.green[600],
                          //               rankKey: 'remaining',
                          //             ),
                          //             CircularSegmentEntry(
                          //               (widget.userData['press_left_count'] /
                          //                       total) *
                          //                   100,
                          //               Colors.red[600],
                          //               rankKey: 'pending',
                          //             ),
                          //             CircularSegmentEntry(
                          //               (20 / total) * 100,
                          //               Colors.grey[100],
                          //               rankKey: 'empty',
                          //             ),
                          //           ],
                          //           rankKey: 'progress',
                          //         ),
                          //       ],
                          //       chartType: CircularChartType.Radial,
                          //       percentageValues: true,
                          //       holeLabel:
                          //           '${((total - 20) / total * 100).toInt()}%',
                          //       labelStyle: TextStyle(
                          //         color: Colors.blueGrey[600],
                          //         fontWeight: FontWeight.bold,
                          //         fontSize: 14.0,
                          //       ),
                          //     ),
                          //     addHorizontalSpace(30),
                          //     Flexible(
                          //       child: Column(
                          //         children: [
                          //           bulletColoredBlackText(
                          //               language == 'ro'
                          //                   ? '${widget.userData['press_left_count']} Comunicate de presă'
                          //                   : '${widget.userData['press_left_count']} Press releases',
                          //               Colors.red),
                          //           bulletColoredBlackText(
                          //               language == 'ro'
                          //                   ? '${widget.userData['interview_left_count']} Interviuri'
                          //                   : '${widget.userData['interview_left_count']} Interviews',
                          //               Colors.blue),
                          //           bulletColoredBlackText(
                          //               language == 'ro'
                          //                   ? '${widget.userData['event_left_count']} Evenimente de presă'
                          //                   : '${widget.userData['event_left_count']} Press events',
                          //               Colors.green),
                          //         ],
                          //       ),
                          //     )
                          //   ],
                          // ),
                          const SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  Center(
                    child: SizedBox(
                      width: 200,
                      child: InkWell(
                        onTap: () {
                          openLogoutDialog(widget.userData['user_language']);
                        },
                        child: tealButton(
                            language == 'ro' ? 'Deconectați-vă' : 'Log out'),
                      ),
                    ),
                  ),
                  addVerticalSpace(90),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     Text(
                  //       'Product of Akilikubwa Co Ltd',
                  //       style: GoogleFonts.quicksand(
                  //         fontSize: 14,
                  //         color: Colors.grey,
                  //         letterSpacing: .5,
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  addVerticalSpace(20),
                ],
              ),
            ),
          )),
    );
  }

  openLogoutDialog(String language) {
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Wrap(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 16,
                    ),
                    Text(
                      language == 'ro' ? 'Deconectați-vă' : 'Log out!',
                      style: GoogleFonts.quicksand(
                        textStyle: const TextStyle(
                          fontSize: 16.0,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          letterSpacing: .5,
                        ),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(
                      height: 6,
                    ),
                    Text(
                      language == 'ro'
                          ? 'Nu veți primi notificări în aplicație când sunteți afară.'
                          : 'You will not receive in-app notifications when you are out.',
                      style: GoogleFonts.quicksand(
                        textStyle: const TextStyle(
                          fontSize: 14.0,
                          color: Colors.black,
                          letterSpacing: .5,
                        ),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: laterButton(
                              language == 'ro' ? 'Anulare' : 'Cancel',
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          flex: 1,
                          child: InkWell(
                            onTap: () {
                              _logOut();
                              Navigator.of(context).pop();
                            },
                            child: dangerButton(
                              language == 'ro' ? 'Deconectați-vă' : 'Logout',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _logOut() async {
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
}
