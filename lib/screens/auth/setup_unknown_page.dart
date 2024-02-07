import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../src/helper_widgets.dart';
import '../../src/theme.dart';
import 'login_screen.dart';

class SetupUnknownPage extends StatefulWidget {
  final String userId;
  const SetupUnknownPage({super.key, required this.userId});

  @override
  State<SetupUnknownPage> createState() => _SetupUnknownPageState();
}

class _SetupUnknownPageState extends State<SetupUnknownPage> {
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
        appBar: AppBar(
          backgroundColor: TAppTheme.primaryColor,
          elevation: 4,
          centerTitle: true,
          title: appBarWhiteText('Restricted Access'),
        ),
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewportConstraints) {
            return SizedBox(
              width: double.infinity,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: viewportConstraints.minHeight,
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        addVerticalSpace(40),
                        Icon(
                          CupertinoIcons.square_arrow_left,
                          size: 48,
                          color: Colors.grey,
                        ),
                        addVerticalSpace(40),
                        blackBoldTextWithSize('Your Access Is Restricted', 18),
                        addVerticalSpace(10),
                        dialogBodyText(
                            'Reserved for companies and journalists. For an optimal experience, please access our web version if you are not authorized for mobile entry'),
                        addVerticalSpace(20),
                        InkWell(
                          onTap: () {
                            logOutUser();
                          },
                          child: simpleButton('Logout'),
                        ),
                        addVerticalSpace(10),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
