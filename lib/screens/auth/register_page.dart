import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:overlay_loader_with_app_icon/overlay_loader_with_app_icon.dart';

import '../../src/helper_widgets.dart';
import '../../src/theme.dart';
import 'verify_email_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final userRef = FirebaseFirestore.instance.collection('Users');
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _loading = false;
  String language = 'ro';
  String email = '';
  String password = '';
  bool _passwordVisible = false;
  final _formKey = GlobalKey<FormState>();
  String _selectedType = 'Company';
  final _controller = ValueNotifier('Company');
  bool isRo = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller.addListener(() {
      setState(() {
        _selectedType = _controller.value;
      });
    });
  }

  Future signUpWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user != null) {
        await credential.user!.sendEmailVerification();
        String userId = credential.user!.uid;
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
              CupertinoPageRoute(
                builder: (context) => VerifyEmailPage(
                  userId: userId,
                ),
              ),
              (r) => false);
        }
      }
    } on FirebaseAuthException catch (e) {
      snackError(isRo ? 'A aparut o eroare' : "An error occurred", context);
    } catch (e) {
      snackError(
          isRo
              ? 'Eroare! verificați și încercați din nou.'
              : "Error! check and try again.",
          context);
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
                                    ? 'Înscrieți-vă la TudoPr'
                                    : 'Sign up to TudoPr',
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
                                isRo ? 'Email' : 'Email',
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
                                  signUpWithEmailAndPassword(email, password);
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
                                isRo ? 'INREGISTREAZA-TE' : 'REGISTER',
                              ),
                            ),
                            addVerticalSpace(20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                InkWell(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      top: 8.0,
                                      bottom: 8.0,
                                      right: 8.0,
                                    ),
                                    child: Text(
                                      isRo ? 'ᐊ Conectare' : 'ᐊ Login',
                                      style: GoogleFonts.quicksand(
                                        textStyle: const TextStyle(
                                          fontSize: 14.0,
                                          color: Colors.black87,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: .5,
                                        ),
                                      ),
                                      textAlign: TextAlign.end,
                                    ),
                                  ),
                                ),
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
}
