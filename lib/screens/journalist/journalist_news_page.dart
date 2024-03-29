import 'package:chips_choice/chips_choice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../src/helper_widgets.dart';
import 'company_events_view.dart';
import 'company_jobs_view.dart';
import 'journalist_news_view.dart';

class JournalistNewsPage extends StatefulWidget {
  final String userId;
  final DocumentSnapshot userData;
  const JournalistNewsPage(
      {super.key, required this.userId, required this.userData});

  @override
  State<JournalistNewsPage> createState() => _JournalistNewsPageState();
}

class _JournalistNewsPageState extends State<JournalistNewsPage> {
  String language = '';
  String category = 'NEWS';
  final Map<String, Map<String, String>> categoryLabels = {
    'ro': {
      'NEWS': 'ȘTIRI',
      'JOBS': 'LOCURI DE MUNCA',
      'EVENTS': 'EVENIMENTE ',
    },
    'eng': {
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
      language = widget.userData['user_language'];
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Container(
      color: Colors.grey.withOpacity(.1),
      height: MediaQuery.of(context).size.height,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              addVerticalSpace(20),
              ChipsChoice<String>.single(
                value: category,
                onChanged: (val) {
                  setState(() {
                    category = val;
                  });
                },
                choiceItems: C2Choice.listFrom<String, String>(
                  source: categoryLabels[language]!.keys.toList(),
                  value: (i, v) => v,
                  label: (i, v) => categoryLabels[language]![v]!,
                ),
                choiceBuilder: (item, index) {
                  return ChoiceChip(
                    label: category == item.value
                        ? whiteChipText(item.label)
                        : blackChipText(item.label),
                    selected: category == item.value,
                    onSelected: (selected) {
                      setState(() {
                        category = item.value;
                      });
                    },
                    selectedColor: Colors
                        .blueGrey, // The background color for selected items
                    backgroundColor: Colors.grey[
                        300], // The background color for non-selected items
                    padding: EdgeInsets.symmetric(horizontal: 10),
                  );
                },
                wrapped: true,
                wrapCrossAlignment: WrapCrossAlignment.start,
                alignment: WrapAlignment.start,
                runAlignment: WrapAlignment.start,
                padding: EdgeInsets.zero,
                spacing: 10,
                runSpacing: 0,
              ),
              addVerticalSpace(10),
              decideView(),
            ],
          ),
        ),
      ),
    );
  }

  Widget decideView() {
    if (category == 'NEWS') {
      return JournalistNewsView(
        userId: widget.userId,
        userData: widget.userData,
      );
    } else if (category == 'JOBS') {
      return CompanyJobsView(
        userId: widget.userId,
        userData: widget.userData,
      );
    } else if (category == 'EVENTS') {
      return CompanyEventsView(
        userId: widget.userId,
        userData: widget.userData,
      );
    } else {
      return JournalistNewsView(
        userId: widget.userId,
        userData: widget.userData,
      );
    }
  }
}
