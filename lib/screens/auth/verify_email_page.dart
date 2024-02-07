import 'dart:async';

import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:overlay_loader_with_app_icon/overlay_loader_with_app_icon.dart';

import '../../screens/auth/login_screen.dart';
import '../../src/helper_widgets.dart';
import '../../src/theme.dart';
import 'setup_account_data.dart';

class VerifyEmailPage extends StatefulWidget {
  final String userId;
  const VerifyEmailPage({super.key, required this.userId});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final bool _loading = false;
  bool _emailVerified = false;
  String _userEmail = '';
  bool isRo = false;

  bool resendingEmail = false;
  bool resendInAction = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _getUser();
    _timer = Timer.periodic(
      const Duration(seconds: 3),
      (Timer t) => _reloadUser(),
    );
  }

  _reloadUser() async {
    var user = _firebaseAuth.currentUser;
    await user!.reload().then((value) {});
    if (user.emailVerified) {
      if (mounted) {
        setState(() {
          _emailVerified = true;
          if (kDebugMode) {
            print('email verified');
          }
          _timer!.cancel();
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _emailVerified = false;
          if (kDebugMode) {
            print('Email not verified');
          }
        });
      }
    }
  }

  _getUser() {
    final User? user = _firebaseAuth.currentUser;
    setState(() {
      _userEmail = user!.email!;
    });
  }

  Future _sendVerificationEmail() async {
    var user = _firebaseAuth.currentUser;
    try {
      await user!.sendEmailVerification().then((value) {
        snackSuccess(
            isRo
                ? "Trimis! Înregistrați și spam-ul."
                : 'Sent! Check in spam too.',
            context);
      });

      if (kDebugMode) {
        print('email sent');
      }
      return user.uid;
    } catch (e) {
      snackError(
          isRo
              ? "Eroare! Trimiterea e-mailului de resetare a eșuat."
              : 'Error! Failed to send reset email.',
          context);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.white,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: OverlayLoaderWithAppIcon(
        isLoading: _loading,
        overlayBackgroundColor: TAppTheme.primaryColor,
        circularProgressColor: TAppTheme.accentColor,
        borderRadius: 15,
        appIcon: const Padding(
          padding: EdgeInsets.all(10),
          child: Icon(
            CupertinoIcons.hourglass,
            size: 28,
            color: TAppTheme.primaryColor,
          ),
        ),
        appIconSize: 50,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              addVerticalSpace(40),
              AnimatedToggleSwitch<bool>.dual(
                current: isRo,
                first: false,
                second: true,
                spacing: 10.0,
                style: const ToggleStyle(
                  borderColor: Colors.transparent,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      spreadRadius: 1,
                      blurRadius: 2,
                      offset: Offset(0, 1.5),
                    ),
                  ],
                ),
                borderWidth: 5.0,
                height: 40,
                onChanged: (val) => setState(() => isRo = val),
                styleBuilder: (b) =>
                    ToggleStyle(indicatorColor: b ? Colors.red : Colors.green),
                iconBuilder: (value) => value
                    ? const Icon(
                        Icons.language,
                        color: Colors.white,
                      )
                    : const Icon(
                        Icons.language,
                        color: Colors.white,
                      ),
                textBuilder: (value) => value
                    ? Center(child: blackBoldText('En'))
                    : Center(child: blackBoldText('Ro')),
              ),
              Expanded(child: Container()),
              addVerticalSpace(30),
              const Icon(
                CupertinoIcons.envelope_badge,
                size: 42,
                color: Colors.blueGrey,
              ),
              addVerticalSpace(40),
              SizedBox(
                height: 300,
                child: _emailVerified ? verifiedView() : unverifiedWidget(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget verifiedView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            blackBoldTextWithSize(isRo ? 'FELICITĂRI!' : 'CONGRATULATIONS', 16),
            addVerticalSpace(10.0),
            dialogBodyText(
              isRo
                  ? 'Adresa de e-mail "$_userEmail" a fost verificată cu succes. Alege tipul de utilizator și continuă configurarea contului tău!'
                  : 'The email address "$_userEmail" was successfully verified. Choose the type of user and continue setting up your account!',
            ),
            addVerticalSpace(20.0),
            InkWell(
              onTap: () {
                Navigator.of(context).pushAndRemoveUntil(
                    CupertinoPageRoute(
                      builder: (context) => SetUpAccountData(
                        userId: widget.userId,
                      ),
                    ),
                    (r) => false);
              },
              child: simpleDarkRoundedButton(
                isRo ? 'Continua!' : 'Continue',
              ),
            ),
            Expanded(
              child: Container(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () async {
                    await _firebaseAuth.signOut().then(
                      (res) {
                        Navigator.of(context).pushAndRemoveUntil(
                            CupertinoPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                            (r) => false);
                      },
                    );
                  },
                  child: Text(
                    isRo ? "Deconectează-te" : 'Log out',
                    style: GoogleFonts.quicksand(
                      textStyle: const TextStyle(
                        fontSize: 14.0,
                        color: Color(0xff1287c3),
                        fontWeight: FontWeight.bold,
                        letterSpacing: .5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            addVerticalSpace(40),
          ],
        ),
      ),
    );
  }

  unverifiedWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            blackBoldTextWithSize(
                isRo ? "CONFIRMARE ADRESĂ DE EMAIL" : 'CONFIRM EMAIL ADDRESS',
                16),
            addVerticalSpace(10.0),
            dialogBodyText(
              isRo
                  ? 'Ți-am trimis un link de verificare pe adresa de e-mail "$_userEmail". Fă click pe link-ul de confirmare pentru a activa contul.'
                  : 'We have sent a verification link to the email address "$_userEmail". Please check your inbox to verify your email.',
            ),
            addVerticalSpace(20.0),
            Container(
              decoration: const BoxDecoration(
                color: Color(0xff33b5e5),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 14,
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Padding(
                          padding: EdgeInsets.only(top: 2.0),
                          child: Icon(
                            Icons.error_outline,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        const SizedBox(
                          width: 2.0,
                        ),
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    isRo
                                        ? 'Dacă nu ați primit linkul de verificare, puteți retrimite din nou.'
                                        : 'If you haven\'t received the verification link, you can resend again.',
                                    style: GoogleFonts.quicksand(
                                      textStyle: const TextStyle(
                                          fontSize: 14.0, color: Colors.white),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 6,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    addVerticalSpace(4.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        InkWell(
                          onTap: () {
                            _sendVerificationEmail();
                          },
                          child: Container(
                              height: 30,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.white,
                                ),
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(15),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14.0),
                                child: Center(
                                  child: whiteNormalText(
                                    isRo ? 'Retrimite' : 'Resend',
                                  ),
                                ),
                              )),
                        ),
                        const SizedBox(width: 10),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            ///resend and refresh
            Expanded(
              child: Container(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () async {
                    await _firebaseAuth.signOut().then(
                      (res) {
                        Navigator.of(context).pushAndRemoveUntil(
                            CupertinoPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                            (r) => false);
                      },
                    );
                  },
                  child: Text(
                    isRo ? "Deconectează-te" : 'Log out',
                    style: GoogleFonts.quicksand(
                      textStyle: const TextStyle(
                        fontSize: 14.0,
                        color: Color(0xff1287c3),
                        fontWeight: FontWeight.bold,
                        letterSpacing: .5,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            addVerticalSpace(40),
          ],
        ),
      ),
    );
  }
}
