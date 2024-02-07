import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'company_news_view.dart';

class CompanyNewsPage extends StatefulWidget {
  final String userId;
  final DocumentSnapshot userData;
  const CompanyNewsPage(
      {super.key, required this.userId, required this.userData});

  @override
  State<CompanyNewsPage> createState() => _CompanyNewsPageState();
}

class _CompanyNewsPageState extends State<CompanyNewsPage> {
  String language = 'ro';
  String category = 'NEWS';
  final Map<String, Map<String, String>> categoryLabels = {
    'ro': {
      'NEWS': 'ȘTIRI',
      'JOBS': 'LOCURI DE MUNCA',
      'EVENTS': 'EVENIMENTE ',
    },
    'en': {
      'NEWS': 'NEWS',
      'JOBS': 'JOBS',
      'EVENTS': 'EVENTS',
    },
  };

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      // language = widget.userData['user_language'];
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Container(
      color: Colors.grey.withOpacity(.1),
      height: MediaQuery.of(context).size.height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CompanyNewsView(
            userId: widget.userId,
            userData: widget.userData,
          ),
        ],
      ),
    );
  }
}
