import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_advanced_segment/flutter_advanced_segment.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
// import 'package:number_selector/number_selector.dart';
import 'package:overlay_loader_with_app_icon/overlay_loader_with_app_icon.dart';

import '../../src/helper_widgets.dart';
import '../../src/theme.dart';
import '../home/home_page.dart';

class SetUpAccountData extends StatefulWidget {
  final String userId;

  const SetUpAccountData({super.key, required this.userId});

  @override
  State<SetUpAccountData> createState() => _SetUpAccountDataState();
}

class _SetUpAccountDataState extends State<SetUpAccountData> {
  final userRef = FirebaseFirestore.instance.collection('Users');
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  String journalistUrl =
      'https://firebasestorage.googleapis.com/v0/b/tudorpr-2023.appspot.com/o/Placeholders%2FProfiles%2Fjournalist_placeholder.png?alt=media&token=eec17514-aba2-4b3f-b876-85603f6d3164';
  String companyUrl =
      'https://firebasestorage.googleapis.com/v0/b/tudorpr-2023.appspot.com/o/Placeholders%2FProfiles%2Fcompany_placeholder.png?alt=media&token=e84ce349-4154-4106-bf1b-8a6725155d43';
  bool _loading = false;
  final _formKey = GlobalKey<FormState>();
  final _journalistFormKey = GlobalKey<FormState>();
  final FirebaseAuth auth = FirebaseAuth.instance;
  bool _errorVisibility = false;
  String journalistName = '';
  String journalistPhone = '';
  String journalistBio = '';
  String companyBio = '';
  String cui = '';
  String registrationNo = '';
  String judet = '';
  String adresa = '';
  String email = '';
  String password = '';
  bool _passwordVisible = false;
  String error = '';
  String language = 'ro';
  bool isRo = false;
  String _selectedType = 'Company';
  final _controller = ValueNotifier('Company');
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController cuiController = TextEditingController();

  ///Termene
  String tUsername = 'OlivianaBijoux';
  String tPassword = '7j!ZVsNq^S';
  String basicAuth = '';
  var data;

  @override
  void initState() {
    super.initState();
    getEmail();
    _controller.addListener(() {
      setState(() {
        _selectedType = _controller.value;
      });
    });
  }

  getEmail() {
    final User? user = auth.currentUser;
    setState(() {
      email = user!.email!;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<bool> getCompanyInfo() async {
    String basicAuth =
        'Basic ${base64Encode(utf8.encode('$tUsername:$tPassword'))}';

    try {
      var response = await http.get(
        Uri.parse("https://termene.ro/api/dateFirmaSumar.php?cui=$cui"),
        headers: <String, String>{
          "Accept": "application/json",
          "authorization": basicAuth,
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          data = json.decode(response.body);
          nameController.text = data['nume'];
          phoneController.text = data['telefon'];
        });
        setState(() {
          _loading = false;
        });
        return true;
      } else {
        if (mounted) {
          snackError(isRo ? 'A apărut o eroare!' : "Error occurred!", context);
        }
        if (kDebugMode) {
          print(response.statusCode);
        }
        setState(() {
          _loading = false;
        });
        return false;
      }
    } catch (e) {
      if (mounted) {
        snackError(isRo ? 'A apărut o eroare!' : "An error occurred!", context);
      }
      print('Error: $e');
      setState(() {
        _loading = false;
      });
      return false;
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
          body: InkWell(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: SingleChildScrollView(
              child: SizedBox(
                width: double.infinity,
                height: MediaQuery.of(context).size.height,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      addVerticalSpace(80),
                      AdvancedSegment(
                        controller: _controller,
                        segments: const {
                          'Company': 'Company',
                          'Journalist': 'Journalist',
                        },
                        activeStyle: GoogleFonts.quicksand(
                          fontSize: 14,
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          letterSpacing: .5,
                        ),
                        inactiveStyle: GoogleFonts.quicksand(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: .5,
                        ),
                        backgroundColor: Colors.black26, // Color
                        sliderColor: Colors.white, // Color
                        sliderOffset: 2.0, // Double
                        borderRadius: const BorderRadius.all(
                            Radius.circular(8.0)), // BorderRadius
                        itemPadding: const EdgeInsets.symmetric(
                          // EdgeInsets
                          horizontal: 15,
                          vertical: 10,
                        ),
                        animationDuration:
                            const Duration(milliseconds: 250), // Duration
                        shadow: const <BoxShadow>[
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8.0,
                          ),
                        ],
                      ),
                      addVerticalSpace(40),
                      _selectedType == 'Company'
                          ? companyBody()
                          : journalistBody(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget companyBody() {
    var size = MediaQuery.of(context).size;
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          blackBoldTextWithSize(
              isRo ? 'Continuați Ca Companie' : 'Continue As Company', 20),
          addVerticalSpace(4.0),
          SizedBox(
            width: size.width - 80,
            child: dialogBodyText(
              isRo
                  ? 'Furnizează-ne CUI-ul companiei tale, iar noi ne ocupăm de restul.'
                  : 'Provide us with your company CUI, and we will handle the rest.',
            ),
          ),
          addVerticalSpace(20.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: size.width / 1.4,
                child: TextFormField(
                  controller: cuiController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp('[0-9]'),
                    ),
                    LengthLimitingTextInputFormatter(10),
                  ],
                  style: GoogleFonts.quicksand(
                    textStyle: const TextStyle(
                      fontSize: 18.0,
                      color: Colors.black54,
                      letterSpacing: .5,
                    ),
                  ),
                  decoration: inputDecorationWithIcon(
                    isRo ? 'Compania CUI' : 'Company CUI',
                    CupertinoIcons.number,
                  ),
                  onChanged: (val) {
                    setState(() {
                      cui = val.trim();
                    });
                  },
                ),
              ),
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey,
                child: IconButton(
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    if (isValidLength(cuiController.text)) {
                      setState(() {
                        _loading = true;
                      });
                      getCompanyInfo();
                    } else {
                      snackError(isRo ? 'CUI nevalid' : 'Invalid CUI', context);
                    }
                  },
                  icon: const Icon(
                    CupertinoIcons.search,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          addVerticalSpace(20.0),
          TextFormField(
            controller: nameController,
            enabled: false,
            keyboardType: TextInputType.text,
            style: GoogleFonts.quicksand(
              textStyle: const TextStyle(
                fontSize: 18.0,
                color: Colors.black54,
                letterSpacing: .5,
              ),
            ),
            decoration: inputDecorationWithIcon(
              isRo ? 'Numele companiei' : 'Company name',
              CupertinoIcons.building_2_fill,
            ),
            onChanged: (val) {
              setState(() {
                // companyName = val.trim();
              });
            },
          ),
          addVerticalSpace(20.0),
          TextFormField(
            controller: phoneController,
            enabled: data != null,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                RegExp('[0-9]'),
              ),
              LengthLimitingTextInputFormatter(13),
            ],
            style: GoogleFonts.quicksand(
              textStyle: const TextStyle(
                fontSize: 18.0,
                color: Colors.black54,
                letterSpacing: .5,
              ),
            ),
            decoration: inputDecorationWithIcon(
              isRo ? 'Număr de telefon' : 'Phone number',
              CupertinoIcons.phone,
            ),
            onChanged: (val) {
              setState(() {
                // companyPhone = val.trim();
              });
            },
          ),
          addVerticalSpace(20.0),
          TextFormField(
            enabled: true,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            inputFormatters: [
              LengthLimitingTextInputFormatter(500),
            ],
            style: GoogleFonts.quicksand(
              textStyle: const TextStyle(
                fontSize: 18.0,
                color: Colors.black54,
                letterSpacing: .5,
              ),
            ),
            decoration: inputDecoration(
              isRo ? 'Despre companie' : 'About company',
              // CupertinoIcons.phone,
            ),
            onChanged: (val) {
              setState(() {
                companyBio = val.trim();
              });
            },
          ),
          const SizedBox(
            height: 30,
          ),
          InkWell(
            onTap: () {
              FocusScope.of(context).unfocus();

              print(companyBio);
              if (nameController.text.isNotEmpty &&
                  phoneController.text.length > 9 &&
                  companyBio.isNotEmpty) {
                setState(() {
                  _loading = true;
                });
                saveCompanyData();
              } else {
                setState(() {
                  _loading = false;
                });
                snackError(
                    isRo
                        ? 'Vă rugăm să completați totul!'
                        : 'Please fill in everything!',
                    context);
              }
            },
            child: simpleRoundedButton(
              language == 'Romanian' ? 'CONTINUA' : 'CONTINUE',
            ),
          ),
          addVerticalSpace(20.0),
        ],
      ),
    );
  }

  saveCompanyData() {
    DocumentReference ds =
        FirebaseFirestore.instance.collection('Users').doc(widget.userId);
    Map<String, dynamic> tasks = {
      'user_name': nameController.text.trim(),
      'about_user': companyBio.trim(),
      'user_nick_name': "-",
      'user_account_type': "Company",
      'user_reference_link': "",
      'user_action_trigger': "new-account",
      'user_email_verification': true,
      'user_account_verification': false,
      'user_profile_completed': false,
      'user_authority': "-",
      'user_email': email,
      'user_id': widget.userId,
      'user_image': companyUrl,
      'user_cui_code': data['cui'],
      'user_phone': phoneController.text.trim(),
      'user_judet': data['judet'],
      'user_localitate': data['localitate'],
      'user_adresa': data['adresa'],
      'user_adresa_anaf': data['adresa_anaf'],
      'user_registration_number': data['cod_inmatriculare'],
      'user_facebook_profile': "-",
      'user_linkedin_profile': "-",
      'user_country': "Romania",
      'user_language': "en",
      'user_links': [],
      'user_id_image': "-",
      'user_badge_image': "-",
      'user_representative_name': "-",
      'user_representative_position': "-",
      'user_representative_email': "-",
      'user_representative_phone': "-",
      'user_representative_linkedin': "-",
      'user_representative_facebook': "-",
      'user_representative_twitter': "-",
      'user_plan': "-",
      'user_device_token': "-",
      'user_account_cretion_date': FieldValue.serverTimestamp(),
      'user_initiated_deletion': false,
      'user_initiated_deletion_time': FieldValue.serverTimestamp(),
      'user_notification_count': 1,
      'user_wallet_balance': 0,
      'user_press_credits': 0,
      'user_interview_credits': 0,
      'user_is_journalist_and_pro': false,
      'user_is_journalist_and_trained': false,
      'user_presses_edited_count': 0,
      'user_interviews_edited_count': 0,
      'user_events_edited_count': 0,
      'user_has_task': false,
      'user_bank_name': "-",
      'user_bank_account_number': "-",
      'user_presses_balance': 0,
      'user_interviews_balance': 0,
      'user_events_balance': 0,
      'user_links_balance': 0,
      'user_mentions_balance': 0,
      'user_package_purchased_time': FieldValue.serverTimestamp(),
      'user_package_duration_in_months': 0,
      'user_notified_on_expiry': false,
      'user_last_interaction': FieldValue.serverTimestamp(),
      'user_posted_presses_count': 0,
      'user_posted_interviews_count': 0,
      'user_posted_events_count': 0,
      'user_posted_links_count': 0,
      'user_posted_mentions_count': 0,
      'user_topic_subscriptions': ["2value"],
      'user_visibility': true,
      'user_extra': "-",

      //analytics
      'user_total_visits': 0,
      'user_total_conversions': 0,
      'user_new_messages': 0,

      //insights
      'user_press_eng_insight':
          "You can publish a press release by pressing the add button.",
      'user_press_ro_insight':
          "Puteți publica un comunicat de presă apăsând butonul de adăugare.",
      'user_interview_eng_insight':
          "You can publish an interview by pressing the add button.",
      'user_interview_ro_insight':
          "Puteți publica un interviu apăsând butonul de adăugare.",
      'user_event_eng_insight':
          "You publish an event by pressing the add button and then selecting events.",
      'user_event_ro_insight':
          "Publicați un eveniment apăsând butonul de adăugare și apoi selectând evenimente.",
      'user_purchase_eng_insight': "You are currently on a DEMO plan.",
      'user_purchase_ro_insight': "În prezent, aveți un plan DEMO.",

      // keep track of drafts
      ///Analytics
      'total_content_traffic': 0, //1034 , 504,
      'total_direct_traffic': 0, //504
      'total_google_traffic': 0, //300
      'total_social_traffic': 0, //200
      'total_other_traffic': 0, //30

      //end
    };
    ds.set(tasks).whenComplete(() {
      setState(() {
        _loading = false;
      });

      ///subscribe to topics
      Navigator.of(context).pushAndRemoveUntil(
          CupertinoPageRoute(
            builder: (context) => HomePage(
              userId: widget.userId,
            ),
          ),
          (r) => false);
    });
  }

  saveJournalistInfo() {
    DocumentReference ds =
        FirebaseFirestore.instance.collection('Users').doc(widget.userId);
    Map<String, dynamic> tasks = {
      'user_name': journalistName.trim(),
      'about_user': journalistBio.trim(),
      'user_nick_name': "-",
      'user_account_type': "Journalist",
      'user_reference_link': "",
      'user_action_trigger': "new-account",
      'user_email_verification': true,
      'user_account_verification': false,
      'user_profile_completed': false,
      'user_authority': "-",
      'user_email': email,
      'user_id': widget.userId,
      'user_image': journalistUrl,
      'user_cui_code': "-",
      'user_phone': journalistPhone,
      'user_judet': "-",
      'user_localitate': "-",
      'user_adresa': "-",
      'user_adresa_anaf': "-",
      'user_registration_number': "-",
      'user_facebook_profile': "-",
      'user_linkedin_profile': "-",
      'user_country': "Romania",
      'user_language': "en",
      'user_links': [],
      'user_id_image': "-",
      'user_badge_image': "-",
      'user_representative_name': "-",
      'user_representative_position': "-",
      'user_representative_email': "-",
      'user_representative_phone': "-",
      'user_representative_linkedin': "-",
      'user_representative_facebook': "-",
      'user_representative_twitter': "-",
      'user_plan': "-",
      'user_device_token': "-",
      'user_account_cretion_date': FieldValue.serverTimestamp(),
      'user_initiated_deletion': false,
      'user_initiated_deletion_time': FieldValue.serverTimestamp(),
      'user_notification_count': 1,
      'user_wallet_balance': 0,
      'user_press_credits': 0,
      'user_interview_credits': 0,
      'user_is_journalist_and_pro': false,
      'user_is_journalist_and_trained': false,
      'user_presses_edited_count': 0,
      'user_interviews_edited_count': 0,
      'user_events_edited_count': 0,
      'user_has_task': false,
      'user_bank_name': "-",
      'user_bank_account_number': "-",
      'user_presses_balance': 0,
      'user_interviews_balance': 0,
      'user_events_balance': 0,
      'user_links_balance': 0,
      'user_mentions_balance': 0,
      'user_package_purchased_time': FieldValue.serverTimestamp(),
      'user_package_duration_in_months': 0,
      'user_notified_on_expiry': false,
      'user_last_interaction': FieldValue.serverTimestamp(),
      'user_posted_presses_count': 0,
      'user_posted_interviews_count': 0,
      'user_posted_events_count': 0,
      'user_posted_links_count': 0,
      'user_posted_mentions_count': 0,
      'user_topic_subscriptions': ["2value"],
      'user_visibility': true,
      'user_extra': "-",

      //analytics
      'user_total_visits': 0,
      'user_total_conversions': 0,
      'user_new_messages': 0,

      //insights
      'user_press_eng_insight':
          "You can start editing press releases by going to the Tasks tab.",
      'user_press_ro_insight':
          "Puteți începe editarea comunicatelor de presă accesând fila Sarcini.",
      'user_interview_eng_insight':
          "You can start editing interviews by going to the Tasks tab.",
      'user_interview_ro_insight':
          "Puteți începe editarea interviurilor accesând fila Sarcini.",
      'user_event_eng_insight':
          "You can view all the events scheduled from the 'From TudoPr' Tab.",
      'user_event_ro_insight':
          "Puteti vizualiza toate evenimentele programate din Tabul 'Din TudoPr'.",
      'user_purchase_eng_insight':
          "You are currently a BASIC journalist, apply for pro.",
      'user_purchase_ro_insight':
          "În prezent sunteți jurnalist BASIC, aplicați pentru pro.",

      // keep track of drafts
      ///Analytics
      'total_content_traffic': 0, //1034 , 504,
      'total_direct_traffic': 0, //504
      'total_google_traffic': 0, //300
      'total_social_traffic': 0, //200
      'total_other_traffic': 0, //30
      //
      //
      //
      // 'user_name': name,
      // 'profile_completed': true,
      // 'user_email': email,
      // 'user_phone': userPhone,
      // 'personal_name_in_company': '-',
      // 'personal_position_in_company': '-',
      // 'registration_number': registrationNo,
      // 'user_address': adresa,
      // 'about_user': '',
      // 'external_link': '',
      // 'user_verification': false,
      // 'subscriptions_count': 0,
      // 'presses_count': 0,
      // 'events_count': 0,
      // 'action_title': 'profile-completed',
      // 'user_cui_code': cui,
      // 'personal_email_in_company': '-',
      // 'personal_phone_in_company': '-',
      // 'personal_facebook_profile': '-',
      // 'personal_linked_in_profile': '-',
      // 'personal_twitter_profile': '-',
      // 'facebook_profile': '',
      // 'linked_in_profile': '',
      // 'twitter_profile': '',
    };
    ds.set(tasks).whenComplete(() {
      setState(() {
        _loading = false;
      });

      ///subscribe to topics
      Navigator.of(context).pushAndRemoveUntil(
          CupertinoPageRoute(
              builder: (context) => HomePage(
                    userId: widget.userId,
                  )),
          (r) => false);
    });
  }

  Widget journalistBody() {
    var size = MediaQuery.of(context).size;
    return Form(
      key: _journalistFormKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          blackBoldTextWithSize(
              isRo ? 'Continuați ca jurnalist' : 'Continue As Journalist', 20),
          addVerticalSpace(4.0),
          SizedBox(
            width: size.width - 80,
            child: dialogBodyText(
              isRo
                  ? 'Sunteți pe cale să vă alăturați TudoPr. Spune-ne puțin despre tine.'
                  : 'You are about to join TudoPr. Tell us a bit about yourself.',
            ),
          ),
          addVerticalSpace(20.0),
          TextFormField(
            enabled: true,
            keyboardType: TextInputType.name,
            inputFormatters: [
              LengthLimitingTextInputFormatter(30),
            ],
            style: GoogleFonts.quicksand(
              textStyle: const TextStyle(
                fontSize: 18.0,
                color: Colors.black54,
                letterSpacing: .5,
              ),
            ),
            decoration: inputDecorationWithIcon(
              isRo ? 'Numele complet' : 'Full name',
              CupertinoIcons.person,
            ),
            onChanged: (val) {
              setState(() {
                journalistName = val.trim();
              });
            },
          ),
          addVerticalSpace(20.0),
          TextFormField(
            enabled: true,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                RegExp('[0-9]'),
              ),
              LengthLimitingTextInputFormatter(13),
            ],
            style: GoogleFonts.quicksand(
              textStyle: const TextStyle(
                fontSize: 18.0,
                color: Colors.black54,
                letterSpacing: .5,
              ),
            ),
            decoration: inputDecorationWithIcon(
              isRo ? 'Număr de telefon' : 'Phone number',
              CupertinoIcons.phone,
            ),
            onChanged: (val) {
              setState(() {
                journalistPhone = val.trim();
              });
            },
            // validator: (val) => val!.length < 10
            //     ? (isRo
            //         ? 'Introduceți un număr de telefon valid'
            //         : 'Enter a valid phone number')
            //     : null,
          ),
          addVerticalSpace(20.0),
          TextFormField(
            keyboardType: TextInputType.text,
            maxLines: null,
            style: GoogleFonts.quicksand(
              textStyle: const TextStyle(
                fontSize: 18.0,
                color: Colors.black54,
                letterSpacing: .5,
              ),
            ),
            decoration: inputDecoration('Bio'),
            onChanged: (val) {
              setState(() {
                journalistBio = val.trim();
              });
            },
            // validator: (val) => val!.length > 18
            //     ? (language == 'Romanian'
            //         ? 'Parola prea lungă'
            //         : 'Password too long')
            //     : null,
          ),
          const SizedBox(
            height: 30,
          ),
          InkWell(
            onTap: () {
              FocusScope.of(context).unfocus();
              if (journalistName.isEmpty ||
                  journalistPhone.length < 10 ||
                  journalistBio.isEmpty) {
                snackError(
                    isRo
                        ? 'Vă rugăm să completați totul!'
                        : 'Please fill in everything!',
                    context);
              } else {
                setState(() {
                  _loading = true;
                });
                saveJournalistInfo();
              }
            },
            child: simpleRoundedButton(
              language == 'Romanian' ? 'Continua' : 'Continue',
            ),
          ),
          const SizedBox(
            height: 30,
          ),
        ],
      ),
    );
  }

  bool isValidLength(String value) {
    // Remove initial 'RO' or 'ro' if present
    String processedValue = value;
    if (processedValue.toUpperCase().startsWith('RO')) {
      processedValue = processedValue.substring(2);
    }

    // Check length constraints: not less than 6 and not greater than 10
    return processedValue.length >= 6 && processedValue.length <= 10;
  }
}
