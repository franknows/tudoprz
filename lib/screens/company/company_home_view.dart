import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../src/helper_widgets.dart';
import 'company_single_press_view.dart';

class CompanyHomeView extends StatefulWidget {
  final String userId;
  final DocumentSnapshot userData;
  const CompanyHomeView(
      {super.key, required this.userId, required this.userData});

  @override
  State<CompanyHomeView> createState() => _CompanyHomeViewState();
}

class _CompanyHomeViewState extends State<CompanyHomeView> {
  String language = '';

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
    return SingleChildScrollView(
      child: Column(
        children: [
          addVerticalSpace(20),
          blackNormalText(widget.userData['user_language'] == 'sw'
              ? 'Sponsored Ad'
              : 'Sponsored Ad'),
          addVerticalSpace(10),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('Ads')
                .where('ad_visibility', isEqualTo: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container(
                  width: size.width - 32,
                  height: (size.width - 32) * 9 / 16,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(.4),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                );
              }

              List<DocumentSnapshot> ads = snapshot.data!.docs;

              return CarouselSlider(
                options: CarouselOptions(
                  height: ((size.width - 32) * 9 / 16),
                  aspectRatio: 16 / 9,
                  autoPlay: true,
                  enlargeCenterPage: true,
                  viewportFraction: 0.9,
                  enlargeFactor: 0.3,
                  scrollDirection: Axis.horizontal,
                ),
                items: ads.map((ad) {
                  String adImage = ad['ad_image'];
                  String adLink = ad['ad_link'];
                  String adDescription = ad['ad_description'];

                  return ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: InkWell(
                      onTap: () {
                        _launchUrl(adLink);
                      },
                      child: Stack(
                        children: [
                          CachedNetworkImage(
                            imageUrl: adImage,
                            placeholder: (context, url) => Image.asset(
                              'assets/images/vertical_placeholder.png',
                              fit: BoxFit.cover,
                            ),
                            errorWidget: (context, url, error) => Image.asset(
                              'assets/images/vertical_placeholder.png',
                              fit: BoxFit.cover,
                            ),
                            width: size.width - 32,
                            height: (size.width - 32) * 9 / 16,
                            fit: BoxFit.cover,
                          ),
                          Container(
                            width: size.width - 32,
                            height: (size.width - 32) * 9 / 16,
                            decoration: const BoxDecoration(
                              // borderRadius: BorderRadius.circular(20.0),
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [Colors.black, Colors.transparent],
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child:
                                      whiteNormalTextMaxLines(adDescription, 2),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          addVerticalSpace(20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    blueBodyTextLarge(
                        language == 'ro' ? 'ACTIVITATE' : 'ACTIVITY'),
                  ],
                ),
                addVerticalSpace(20),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('Articles')
                      .doc('Presses')
                      .collection('Dominant')
                      .where('press_poster', isEqualTo: widget.userId)
                      .orderBy('press_time', descending: true)
                      .limit(10)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return emptyList(size.width);
                    } else {
                      if (snapshot.data!.docs.isEmpty) {
                        return emptyList(size.width);
                      } else {
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            DocumentSnapshot doc = snapshot.data!.docs[index];
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
                              child: pressItem(doc),
                            );
                          },
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
          addVerticalSpace(20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    blueBodyTextLarge(
                        language == 'ro' ? 'LOCURI DE MUNCA' : 'JOBS'),
                  ],
                ),
                addVerticalSpace(20),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('Articles')
                      .doc('Presses')
                      .collection('Dominant')
                      .where('press_poster', isEqualTo: widget.userId)
                      .orderBy('press_time', descending: true)
                      .limit(10)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return emptyList(size.width);
                    } else {
                      if (snapshot.data!.docs.isEmpty) {
                        return emptyList(size.width);
                      } else {
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            DocumentSnapshot doc = snapshot.data!.docs[index];
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
                              child: pressItem(doc),
                            );
                          },
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
          addVerticalSpace(20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    blueBodyTextLarge(
                        language == 'ro' ? 'EVENIMENTE' : 'EVENTS'),
                  ],
                ),
                addVerticalSpace(20),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('Articles')
                      .doc('Presses')
                      .collection('Dominant')
                      .where('press_poster', isEqualTo: widget.userId)
                      .orderBy('press_time', descending: true)
                      .limit(10)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return emptyList(size.width);
                    } else {
                      if (snapshot.data!.docs.isEmpty) {
                        return emptyList(size.width);
                      } else {
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            DocumentSnapshot doc = snapshot.data!.docs[index];
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
                              child: pressItem(doc),
                            );
                          },
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url),
        mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  Widget emptyList(double width) {
    return SizedBox(
      height: width,
      child: const Center(
        child: Image(
          height: 200,
          image: AssetImage('assets/images/empty_list.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
