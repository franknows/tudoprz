import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:overlay_loader_with_app_icon/overlay_loader_with_app_icon.dart';
import 'package:tudopr/screens/auth/verify_email_page.dart';

import '../../src/helper_widgets.dart';
import '../../src/theme.dart';
import '../home/home_page.dart';
import 'register_page.dart';
import 'reset_password.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final userRef = FirebaseFirestore.instance.collection('Users');
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  bool _loading = false;
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String email = '';
  String password = '';
  bool _passwordVisible = false;
  bool isRo = false;

  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      if (userCredential.user != null) {
        String userId = userCredential.user!.uid;
        if (mounted) {
          checkUserStatus(userId, context);
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _loading = false;
      });
      print(e.code);
      print(e.message);

      snackError(isRo ? 'A aparut o eroare!' : 'Error occured!', context);
    }
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
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
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
                              styleBuilder: (b) => ToggleStyle(
                                  indicatorColor:
                                      b ? Colors.red : Colors.green),
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
                            const Center(
                              child: Image(
                                height: 80,
                                width: 80,
                                image: AssetImage(
                                  'assets/images/play_logo.png',
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                            addVerticalSpace(40),
                            blackBoldTextWithSize(
                                isRo
                                    ? 'Conectați-vă la TudoPr'
                                    : 'Sign in to TudoPr',
                                20),
                            addVerticalSpace(30),
                            TextFormField(
                              keyboardType: TextInputType.emailAddress,
                              style: GoogleFonts.quicksand(
                                textStyle: const TextStyle(
                                  fontSize: 18.0,
                                  color: Colors.black54,
                                  letterSpacing: .5,
                                ),
                              ),
                              decoration: inputDecorationWithIcon(
                                isRo ? 'E-mail' : 'E-mail',
                                CupertinoIcons.envelope,
                              ),
                              onChanged: (val) {
                                setState(() {
                                  email = val.trim();
                                });
                              },
                              validator: (val) =>
                                  !RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                                          .hasMatch(val!)
                                      ? (isRo
                                          ? 'Adresa email invalida'
                                          : 'Invalid email address')
                                      : null,
                            ),
                            addVerticalSpace(20.0),
                            TextFormField(
                              keyboardType: TextInputType.text,
                              obscureText: !_passwordVisible,
                              style: GoogleFonts.quicksand(
                                textStyle: const TextStyle(
                                  fontSize: 18.0,
                                  color: Colors.black54,
                                  letterSpacing: .5,
                                ),
                              ),
                              decoration: InputDecoration(
                                filled: true,
                                labelText: isRo ? 'Parola' : 'Password',
                                labelStyle: GoogleFonts.quicksand(
                                  textStyle: const TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: .5,
                                  ),
                                ),
                                helperStyle: GoogleFonts.quicksand(
                                  textStyle: const TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.black54,
                                    letterSpacing: .5,
                                  ),
                                ),
                                errorStyle: GoogleFonts.quicksand(
                                  textStyle: const TextStyle(
                                    fontSize: 12.0,
                                    color: TAppTheme.errorColor,
                                    letterSpacing: .5,
                                  ),
                                ),
                                prefixIconColor: Colors.blueGrey,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 0.0,
                                  horizontal: 4.0,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    width: 1.5,
                                    color: Colors.grey,
                                  ),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      width: 1.5, color: Colors.redAccent),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      width: 1.5, color: Colors.grey),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      width: 1.5, color: Colors.red),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                prefixIcon: const Icon(
                                  CupertinoIcons.lock,
                                  color: Colors.blueGrey,
                                  size: 18,
                                  // size: 18,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _passwordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Theme.of(context).primaryColorDark,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _passwordVisible = !_passwordVisible;
                                    });
                                  },
                                ),
                              ),
                              onChanged: (val) {
                                setState(() {
                                  password = val.trim();
                                });
                              },
                            ),
                            addVerticalSpace(30),
                            InkWell(
                              onTap: () {
                                FocusScope.of(context).unfocus();
                                if (_formKey.currentState!.validate()) {
                                  setState(() {
                                    _loading = true;
                                  });
                                  signInWithEmailAndPassword(email, password);
                                } else {
                                  snackError(
                                      (isRo
                                          ? 'Vă rog să umpleți totul!'
                                          : 'Please fill everything!'),
                                      context);
                                  setState(
                                    () {
                                      _loading = false;
                                    },
                                  );
                                }
                              },
                              child: simpleRoundedButton(
                                isRo ? 'AUTENTIFICARE' : 'LOGIN',
                              ),
                            ),
                            addVerticalSpace(20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                        builder: (_) => const ResetPassword(),
                                      ),
                                    );
                                  },
                                  child: SizedBox(
                                    width: 140,
                                    height: 40,
                                    child: Center(
                                      child: Text(
                                        isRo
                                            ? 'Resetare parola'
                                            : 'Reset password',
                                        style: GoogleFonts.quicksand(
                                          textStyle: const TextStyle(
                                            fontSize: 14.0,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: .5,
                                          ),
                                        ),
                                        textAlign: TextAlign.end,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  height: 14,
                                  width: 1,
                                  color: Colors.grey,
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                        builder: (_) => const RegisterPage(),
                                      ),
                                    );
                                  },
                                  child: SizedBox(
                                    width: 140,
                                    height: 40,
                                    child: Center(
                                      child: Text(
                                        isRo ? 'Inscrie-te' : 'Register',
                                        style: GoogleFonts.quicksand(
                                          textStyle: const TextStyle(
                                            fontSize: 14.0,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: .5,
                                          ),
                                        ),
                                        textAlign: TextAlign.start,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            addVerticalSpace(40),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> doesUserExist(String userId) async {
    final userRef = FirebaseFirestore.instance.collection('Users').doc(userId);
    final userDoc = await userRef.get();
    return userDoc.exists;
  }

  Future<void> checkUserStatus(String uid, BuildContext context) async {
    bool userExists = await doesUserExist(uid);
    if (userExists) {
      ///update device token
      // final fcmToken = await messaging.getToken();
      messaging.getToken().then((token) {
        userRef.doc(uid).update({
          'user_device_token': token,
          'user_last_interaction': FieldValue.serverTimestamp(),
        }).then((value) {
          Navigator.of(context).pushAndRemoveUntil(
            CupertinoPageRoute(
              builder: (context) => HomePage(userId: uid),
            ),
            (r) => false,
          );
        }).catchError((error) {
          // print("Failed to update token: $error");
        });
      }).catchError((error) {
        // print('Failed to get token: $error');
      });
    } else {
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          CupertinoPageRoute(
            builder: (context) => VerifyEmailPage(userId: uid),
          ),
          (r) => false,
        );
      }
    }
  }
}
