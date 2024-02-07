import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import "package:http/http.dart" as http;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:overlay_loader_with_app_icon/overlay_loader_with_app_icon.dart';

import '../../src/helper_widgets.dart';
import '../../src/theme.dart';

class CompanyGeneratePressReleasePage extends StatefulWidget {
  final String userId;
  final DocumentSnapshot userData;
  const CompanyGeneratePressReleasePage(
      {super.key, required this.userId, required this.userData});

  @override
  State<CompanyGeneratePressReleasePage> createState() =>
      _CompanyGeneratePressReleasePageState();
}

class _CompanyGeneratePressReleasePageState
    extends State<CompanyGeneratePressReleasePage> {
  final _formKey = GlobalKey<FormState>();
  String language = '';
  int step = 0;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _textController = TextEditingController();
  int mills = DateTime.now().millisecondsSinceEpoch;

  bool loading = false;
  String pressTitle = '';
  String pressSummary = '';
  String pressBody = '';
  File? _imageFile;
  final String _uploadedFileURL = '-';
  int? selectedOption;
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
    'eng': {
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

  final TextEditingController _promptController = TextEditingController();

  bool generated = false;
  Map<String, dynamic> jsonObject = {};
  bool typingLink = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      language = widget.userData['user_language'];
    });
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  final List<Map<String, String>> messages = [];
  final String nOpenAiKey =
      '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';

  Future<String> chatGPTAPI(String prompt) async {
    setState(() {
      loading = true;
    });
    String instructions =
        'Reply only with a JSON response. Create a press release from this input text: [$prompt]. I want your JSON response to be a valid JSON array of objects following this format: [{"title": "The generated title", "summary": "The generated summary of the press release", "body": "The body of the press release",}]. The values of the keys should use the language of the input text.';
    messages.add({
      'role': 'user',
      'content': instructions,
    });
    try {
      final res = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $nOpenAiKey',
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "messages": messages,
        }),
      );

      if (res.statusCode == 200) {
        String content =
            jsonDecode(res.body)['choices'][0]['message']['content'].trim();
        List<Map<String, dynamic>> dataList =
            List<Map<String, dynamic>>.from(jsonDecode(content));
        setState(() {
          jsonObject = dataList[0];
          generated = true;
        });
        print(content);

        messages.add({
          'role': 'assistant',
          'content': content,
        });
        setState(() {
          loading = false;
        });
        return content;
      }
      return 'An internal error occurred';
    } catch (e) {
      print(e);
      setState(() {
        loading = false;
      });
      snackError('Error! $e', context);
      return e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.white,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
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
            backgroundColor: TAppTheme.primaryColor,
            elevation: 4,
            title: appBarWhiteText(
              language == 'ro' ? 'Comunicat de presă' : 'Press release',
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ///press prompt
                    generated
                        ? Container()
                        : Column(
                            children: [
                              leftInstructor(
                                width - 32,
                                'assets/personas/first_male.png',
                                language == 'ro'
                                    ? 'Povestește-ne puțin despre comunicatul tău de presă și lasă instrumentele noastre AI să facă restul.'
                                    : 'Tell us a bit about your press release and let our AI tools do the rest.',
                              ),
                              addVerticalSpace(20.0),
                              CustomTextFormField(
                                labelText:
                                    language == 'ro' ? 'Prompt' : 'Prompt',
                                hintText: "",
                                controller: _promptController,
                                keyboardType: TextInputType.multiline,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return (language == 'ro'
                                        ? 'Prea scurt'
                                        : 'Too short');
                                  }
                                  return null;
                                },
                              ),
                              addVerticalSpace(20),
                              InkWell(
                                onTap: () {
                                  chatGPTAPI(_promptController.text);
                                },
                                child: simpleDarkRoundedButton('Generate'),
                              ),
                            ],
                          ),
                    generated
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              addVerticalSpace(20),
                              blackBoldText(jsonObject['title']),
                              addVerticalSpace(4.0),
                              greyNormalText(jsonObject['summary']),
                              addVerticalSpace(4.0),
                              blackNormalText(jsonObject['body']),
                              addVerticalSpace(10.0),
                              blackBoldText('About Company'),
                              addVerticalSpace(4.0),
                              blackNormalText(widget.userData['about_user']),
                              addVerticalSpace(40.0),
                            ],
                          )
                        : Container(),
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
      // _uploadImage(context);
    } else {
      loading = false;
      snackError(
          widget.userData['user_language'] == 'ro'
              ? 'Te rugăm să completezi toate câmpurile!'
              : 'Please fill everything',
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
