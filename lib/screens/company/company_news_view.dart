import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../src/helper_widgets.dart';
import '../../src/theme.dart';
import 'company_single_press_view.dart';

class CompanyNewsView extends StatefulWidget {
  final String userId;
  final DocumentSnapshot userData;
  const CompanyNewsView(
      {super.key, required this.userId, required this.userData});

  @override
  State<CompanyNewsView> createState() => _CompanyNewsViewState();
}

class _CompanyNewsViewState extends State<CompanyNewsView> {
  String language = '';
  int _limit = 20; // Initial limit, change as needed
  int total = 20;
  QuerySnapshot? query;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getCompanies(_limit);
    setState(() {
      language = widget.userData['user_language'];
    });
  }

  void _getCompanies(int limit) {
    FirebaseFirestore.instance
        .collection('Articles')
        .doc('Presses')
        .collection('Dominant')
        .where('press_status', isEqualTo: 'LIVE')
        .orderBy('press_time', descending: true)
        .limit(limit)
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      setState(() {
        query = snapshot;
        total = snapshot.size;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    if (query == null) {
      return SizedBox(
        height: size.height - 300,
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 4,
            color: TAppTheme.primaryColor.withOpacity(.4),
            backgroundColor: Colors.white,
          ),
        ),
      );
    } else {
      if (query!.size == 0) {
        return Column(
          children: [
            addVerticalSpace(200),
            const Center(
              child: Image(
                height: 200,
                image: AssetImage('assets/images/empty_list.png'),
              ),
            ),
          ],
        );
      } else {
        return SingleChildScrollView(
          child: Column(
            children: [
              ListView.builder(
                padding: const EdgeInsets.all(16),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: query!.docs.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot doc = query!.docs[index];
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (_) => CompanySinglePressView(
                            userId: widget.userId,
                            userData: widget.userData,
                            pressData: doc,
                          ),
                        ),
                      );
                    },
                    child: pressPublicItem(doc),
                  );
                },
              ),
              if (_limit <= total)
                SizedBox(
                  width: 200,
                  child: GestureDetector(
                    onTap: () {
                      _getCompanies(_limit + 20);
                      setState(() {
                        _limit += 20; // Add 10 more items
                      });
                    },
                    child: tealButton(
                      language == 'ro' ? 'Incarca mai mult' : 'Load More',
                    ),
                  ),
                ),
              addVerticalSpace(20),
            ],
          ),
        );
      }
    }
  }
}
