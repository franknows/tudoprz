import 'dart:io';

import 'package:chips_choice/chips_choice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:overlay_loader_with_app_icon/overlay_loader_with_app_icon.dart';

import '../../src/helper_widgets.dart';
import '../../src/theme.dart';

class CompanyAddPressReleasePage extends StatefulWidget {
  final String userId;
  final DocumentSnapshot userData;
  const CompanyAddPressReleasePage(
      {super.key, required this.userId, required this.userData});

  @override
  State<CompanyAddPressReleasePage> createState() =>
      _CompanyAddPressReleasePageState();
}

class _CompanyAddPressReleasePageState
    extends State<CompanyAddPressReleasePage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  int mills = DateTime.now().millisecondsSinceEpoch;
  bool isRo = false;
  bool loading = false;
  String pressTitle = '';
  String pressSummary = '';
  String pressBody = '';
  String aboutCompany = '';
  String pressLink = '';
  String pressTags = '';
  String pressAuthor = '';
  File? _imageFile;
  bool checkBoxValue = false;
  List<String> categories = [];
  final Map<String, Map<String, String>> categoryLabels = {
    'ro': {
      'CONSTRUCTIONS': 'CONSTRUCȚII',
      'EVENT': 'EVENIMENT',
      'TECH': 'TECH',
      'POLITICAL': 'POLITIC',
      'ECONOMIC': 'ECONOMIC',
      'HEALTH': 'SĂNĂTATE',
      'HOSPITALITY': 'HORECA',
      'LIFESTYLE': 'LIFESTYLE',
      'SOCIAL': 'SOCIAL',
    },
    'en': {
      'CONSTRUCTIONS': 'CONSTRUCTIONS',
      'EVENT': 'EVENT',
      'TECH': 'TECH',
      'POLITICAL': 'POLITICAL',
      'ECONOMIC': 'ECONOMIC',
      'HEALTH': 'HEALTH',
      'HOSPITALITY': 'HOSPITALITY',
      'LIFESTYLE': 'LIFESTYLE',
      'SOCIAL': 'SOCIAL',
    },
  };

  @override
  void initState() {
    super.initState();
    setState(() {
      isRo = widget.userData['user_language'] == 'ro';
    });
  }

  Future<void> _uploadImage(BuildContext context) async {
    final DateTime now = DateTime.now();
    final String year = DateFormat('yyyy').format(now);

    try {
      Reference pressStorageReference = FirebaseStorage.instance.ref().child(
          'Articles/Presses/$year/${now.millisecondsSinceEpoch.toString()}.jpg');
      UploadTask uploadTask = pressStorageReference.putFile(_imageFile!);

      uploadTask.whenComplete(() async {
        String url = await pressStorageReference.getDownloadURL();

        if (mounted) {
          savePress(url);
        }
      }).catchError((onError) {
        setState(() {
          loading = false;
        });
        snackError(
          widget.userData['user_language'] == 'ro'
              ? 'A apărut o eroare, încercați din nou.'
              : 'An error occurred, try again',
          context,
        );
      });
    } on FirebaseException catch (e) {
      setState(() {
        loading = false;
      });
      snackError(
        widget.userData['user_language'] == 'ro'
            ? 'A apărut o eroare, încercați din nou.'
            : 'An error occurred, try again',
        context,
      );
    }
  }

  savePress(String url) {
    DocumentReference pressRef = FirebaseFirestore.instance
        .collection('Articles')
        .doc('Presses')
        .collection('Dominant')
        .doc(widget.userId);
    Map<String, dynamic> prompt = {
      'press_title': pressTitle,
      'press_summary': pressSummary,
      'press_body_html': pressBody,
      'press_about_company': aboutCompany,
      'press_author': pressAuthor,
      'press_image': url,
      'press_time': FieldValue.serverTimestamp(),
      'press_poster': widget.userId,
      'press_poster_email': widget.userData['user_email'],
      'press_linked_url': pressLink,
      'press_categories': categories,
      'press_tags': categories,
      'press_loop_status':
          "2", //0: DRAFT 1: Journalist 2: Editor 3: Company 4: Reserved 5: LIVE
      'press_status': '-',
      'press_circulation_life': 0,
      'press_active_editing_user': "-",
      'press_journalist_editor': "-",
      'press_journalist_email': "-",
      'press_tudopr_editor': "-",
      'press_tudopr_editor_email': "-",
      'press_id': "-",
      'press_action_title': "-",
      'press_journalist_take_over_time': FieldValue.serverTimestamp(),
      'press_company_can_chat': true,
      'press_journalist_can_chat': true,

      ///Analytics data
      'press_total_traffic_count': 0,
      'press_unique_traffic_count': 0,
      'press_facebook_traffic_count': 0,
      'press_linkedIn_traffic_count': 0,
      'press_twitter_traffic_count': 0,
      'press_whatsApp_traffic_count': 0,
      'press_google_traffic_count': 0,
      'press_direct_traffic_count': 0,
      'press_other_traffic_count': 0,
      'press_notifications_count': 0,
      'press_extra': "-",

      ///end
    };
    pressRef.set(prompt, SetOptions(merge: true)).then((value) {
      setState(() {
        loading = false;
      });
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
      ),
      child: OverlayLoaderWithAppIcon(
        isLoading: loading,
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
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 2,
            title: Text(
              isRo ? 'Comunicat de presă' : 'Press release',
              style: GoogleFonts.quicksand(
                textStyle: const TextStyle(
                  color: Colors.black87,
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
                color: Colors.black87,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    addVerticalSpace(20),
                    Center(
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Container(
                          //height: 160.0,
                          width: double.infinity,
                          child: InkWell(
                            child: _imageFile == null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(10.0),
                                    child: const Image(
                                      image: AssetImage(
                                        'assets/images/place_holder.png',
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(10.0),
                                    child: Image(
                                      image: FileImage(_imageFile!),
                                      fit: BoxFit.cover,
                                      //child: Text('Select Image'),
                                    ),
                                  ),
                            onTap: () {
                              getImage();
                            },
                          ),
                        ),
                      ),
                    ),
                    addVerticalSpace(20),
                    TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        style: GoogleFonts.quicksand(
                          textStyle: const TextStyle(
                            fontSize: 18.0,
                            color: Colors.black54,
                            letterSpacing: .5,
                          ),
                        ),
                        decoration: inputDecoration(
                          isRo
                              ? 'Titlul comunicatului de presă'
                              : 'Title of the press release',
                        ),
                        onChanged: (val) {
                          setState(() {
                            pressTitle = val.trim();
                          });
                        },
                        validator: (val) {
                          if (val!.isEmpty) {
                            return (isRo ? 'Prea scurt' : 'Too short');
                          }
                          return null;
                        }),
                    addVerticalSpace(20),
                    TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        style: GoogleFonts.quicksand(
                          textStyle: const TextStyle(
                            fontSize: 18.0,
                            color: Colors.black54,
                            letterSpacing: .5,
                          ),
                        ),
                        decoration: inputDecoration(
                          isRo ? 'Introducere articol' : 'Article introduction',
                        ),
                        onChanged: (val) {
                          setState(() {
                            pressSummary = val.trim();
                          });
                        },
                        validator: (val) {
                          if (val!.isEmpty) {
                            return (isRo ? 'Prea scurt' : 'Too short');
                          }
                          return null;
                        }),

                    addVerticalSpace(20),
                    ChipsChoice<String>.multiple(
                      value: categories,
                      onChanged: (val) {
                        setState(() {
                          categories = val;
                        });
                      },
                      choiceItems: C2Choice.listFrom<String, String>(
                        source:
                            categoryLabels[isRo ? 'ro' : 'en']!.keys.toList(),
                        value: (i, v) => v,
                        label: (i, v) =>
                            categoryLabels[isRo ? 'ro' : 'en']![v]!,
                      ),
                      choiceBuilder: (item, index) {
                        return ChoiceChip(
                          label: categories.contains(item.value)
                              ? whiteChipText(item.label!)
                              : blackChipText(item.label!),
                          selected: categories.contains(item.value),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                categories.add(item.value!);
                              } else {
                                categories.remove(item.value);
                              }
                            });
                          },
                          selectedColor: Colors
                              .blueGrey, // The background color for selected items
                          backgroundColor: Colors.grey[
                              200], // The background color for non-selected items
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        );
                      },
                      wrapped: true,
                      wrapCrossAlignment: WrapCrossAlignment.start,
                      alignment: WrapAlignment.start,
                      runAlignment: WrapAlignment.start,
                      padding: EdgeInsets.zero,
                      spacing: 6,
                      runSpacing: 0,
                    ),

                    addVerticalSpace(20),
                    TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        style: GoogleFonts.quicksand(
                          textStyle: const TextStyle(
                            fontSize: 18.0,
                            color: Colors.black54,
                            letterSpacing: .5,
                          ),
                        ),
                        decoration: inputDecoration(
                          isRo
                              ? 'Corpul comunicatului de presă'
                              : 'Body of the press release',
                        ),
                        onChanged: (val) {
                          setState(() {
                            pressBody = val.trim();
                          });
                        },
                        validator: (val) {
                          if (val!.isEmpty) {
                            return (isRo ? 'Prea scurt' : 'Too short');
                          }
                          return null;
                        }),

                    addVerticalSpace(20),
                    TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        style: GoogleFonts.quicksand(
                          textStyle: const TextStyle(
                            fontSize: 18.0,
                            color: Colors.black54,
                            letterSpacing: .5,
                          ),
                        ),
                        decoration: inputDecoration(
                          isRo ? 'Despre companie' : 'About company',
                        ),
                        onChanged: (val) {
                          setState(() {
                            aboutCompany = val.trim();
                          });
                        },
                        validator: (val) {
                          if (val!.isEmpty) {
                            return (isRo ? 'Prea scurt' : 'Too short');
                          }
                          return null;
                        }),

                    addVerticalSpace(20),
                    TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        style: GoogleFonts.quicksand(
                          textStyle: const TextStyle(
                            fontSize: 18.0,
                            color: Colors.black54,
                            letterSpacing: .5,
                          ),
                        ),
                        decoration: inputDecoration(
                          isRo ? 'Link suplimentar' : 'Additional link',
                        ),
                        onChanged: (val) {
                          setState(() {
                            pressLink = val.trim();
                          });
                        },
                        validator: (val) {
                          if (val!.isEmpty) {
                            return (isRo ? 'Prea scurt' : 'Too short');
                          }
                          return null;
                        }),

                    addVerticalSpace(20),
                    TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        style: GoogleFonts.quicksand(
                          textStyle: const TextStyle(
                            fontSize: 18.0,
                            color: Colors.black54,
                            letterSpacing: .5,
                          ),
                        ),
                        decoration: inputDecoration(
                          isRo ? 'Etichete relevante' : 'Relevant tags',
                        ),
                        onChanged: (val) {
                          setState(() {
                            pressTags = val.trim();
                          });
                        },
                        validator: (val) {
                          if (val!.isEmpty) {
                            return (isRo ? 'Prea scurt' : 'Too short');
                          }
                          return null;
                        }),

                    addVerticalSpace(20),
                    TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        style: GoogleFonts.quicksand(
                          textStyle: const TextStyle(
                            fontSize: 18.0,
                            color: Colors.black54,
                            letterSpacing: .5,
                          ),
                        ),
                        decoration: inputDecoration(
                          isRo ? 'Numele autorului' : 'Name of the author',
                        ),
                        onChanged: (val) {
                          setState(() {
                            pressAuthor = val.trim();
                          });
                        },
                        validator: (val) {
                          if (val!.isEmpty) {
                            return (isRo ? 'Prea scurt' : 'Too short');
                          }
                          return null;
                        }),

                    ///submit button
                    addVerticalSpace(40),
                    InkWell(
                        onTap: () {
                          submitPressed();
                        },
                        child: simpleDarkRoundedButton('Submit')),
                    addVerticalSpace(60),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  submitPressed() {
    FocusScope.of(context).unfocus();

    if (categories.isEmpty) {
      loading = false;
      snackError(
          widget.userData['user_language'] == 'ro'
              ? 'Te rugăm să completezi toate câmpurile!'
              : 'Please fill everything',
          context);
    } else if (_imageFile == null) {
      loading = false;
      snackError(
          widget.userData['user_language'] == 'ro'
              ? 'Te rugăm să completezi toate câmpurile!'
              : 'Please fill everything',
          context);
    } else if (_formKey.currentState!.validate()) {
      setState(() {
        loading = true;
      });
      _uploadImage(context);
    } else {
      loading = false;
      snackError(
          widget.userData['user_language'] == 'ro'
              ? 'Vă rog să umpleți totul!'
              : 'Please fill everything!',
          context);
    }
  }

  Future<void> getImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image == null) {
      return;
    }

    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: image.path,
        aspectRatio: const CropAspectRatio(
          ratioX: 16,
          ratioY: 9,
        ),
        maxHeight: 1080,
        maxWidth: 1920,
        compressQuality: 70,
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: 'Crop image',
              toolbarColor: TAppTheme.primaryColor,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: true),
          IOSUiSettings(
            title: 'Crop image',
          ),
        ],
      );

      if (croppedFile != null) {
        setState(() {
          final file = File(croppedFile.path);
          _imageFile = file;
        });
      }
    } catch (e) {
      // Handle any errors that occurred during image cropping.
    }
  }
}
