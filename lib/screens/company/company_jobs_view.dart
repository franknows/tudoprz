import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../src/helper_widgets.dart';
import '../../src/theme.dart';
import '../../src/time_ago_eng.dart';

class CompanyJobsView extends StatefulWidget {
  final String userId;
  final DocumentSnapshot userData;
  const CompanyJobsView(
      {super.key, required this.userId, required this.userData});

  @override
  State<CompanyJobsView> createState() => _CompanyJobsViewState();
}

class _CompanyJobsViewState extends State<CompanyJobsView> {
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
        .collection('XJobs')
        .where('job_visibility', isEqualTo: true)
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
        return Flexible(
          child: SingleChildScrollView(
            child: Column(
              children: [
                ListView.builder(
                  padding: const EdgeInsets.only(
                    bottom: 20,
                    left: 16,
                    right: 16,
                    top: 16,
                  ),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: query!.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot doc = query!.docs[index];
                    return InkWell(
                      onTap: () {
                        // Navigator.push(
                        //   context,
                        //   CupertinoPageRoute(
                        //     builder: (_) => AdminSinglePressView(
                        //       userId: widget.userId,
                        //       userData: widget.userData,
                        //       pressData: doc,
                        //     ),
                        //   ),
                        // );
                        _showBottomSheet(context, doc);
                      },
                      child: jobPublicItem(doc),
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
          ),
        );
      }
    }
  }

  void _showBottomSheet(BuildContext context, DocumentSnapshot doc) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
          child: Container(
            // height: 480, // you can adjust this value as needed
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  addVerticalSpace(16),
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: SizedBox(
                          height: 50,
                          width: 50,
                          child: CachedNetworkImage(
                            imageUrl: doc['job_employer_logo'],
                            placeholder: (context, url) => Image.asset(
                              'assets/images/vertical_placeholder.png',
                              fit: BoxFit.cover,
                            ),
                            errorWidget: (context, url, error) => Image.asset(
                              'assets/images/vertical_placeholder.png',
                              fit: BoxFit.cover,
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      addHorizontalSpace(20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doc['job_employer_name'],
                            style: GoogleFonts.quicksand(
                              fontSize: 14,
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                              letterSpacing: .5,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          addVerticalSpace(4),
                          miniBlackText(timeAgoEn(doc['job_posted_mills']))
                        ],
                      ),
                    ],
                  ),
                  addVerticalSpace(10),
                  Text(
                    doc['job_title'].toString().toUpperCase(),
                    style: GoogleFonts.quicksand(
                      fontSize: 14,
                      color: Colors.black54,
                      fontWeight: FontWeight.bold,
                      letterSpacing: .5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  addVerticalSpace(4.0),
                  Text(
                    doc['job_description'],
                    style: GoogleFonts.quicksand(
                      fontSize: 14,
                      color: Colors.black54,
                      letterSpacing: .5,
                    ),
                    // overflow: TextOverflow.ellipsis,
                  ),
                  addVerticalSpace(20.0),
                  GestureDetector(
                    onTap: () {
                      _launchUrl(doc['job_application_link']);
                    },
                    child: simpleDarkRoundedButton(
                        language == 'ro' ? 'Aplica job' : 'Apply job'),
                  ),
                  addVerticalSpace(60.0),
                ],
              ),
            ),
          ),
        );
      },
      backgroundColor: Colors
          .transparent, // To ensure no color is applied outside the ClipRRect
    );
  }

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url),
        mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }
}
