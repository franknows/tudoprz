import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../src/helper_widgets.dart';

class JournalistHomeView extends StatefulWidget {
  final String userId;
  final DocumentSnapshot userData;
  const JournalistHomeView(
      {super.key, required this.userId, required this.userData});

  @override
  State<JournalistHomeView> createState() => _JournalistHomeViewState();
}

class _JournalistHomeViewState extends State<JournalistHomeView> {
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
    return Container(
      color: Colors.grey.withOpacity(.1),
      height: MediaQuery.of(context).size.height,
      child: SingleChildScrollView(
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
                  return SizedBox(
                    width: MediaQuery.of(context).size.width - 32,
                    height: (MediaQuery.of(context).size.width - 32) * 9 / 16,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                List<DocumentSnapshot> ads = snapshot.data!.docs;

                return Container(
                  color: Colors.transparent,
                  child: CarouselSlider(
                    options: CarouselOptions(
                      height:
                          ((MediaQuery.of(context).size.width - 32) * 9 / 16) +
                              90,
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
                      String adCta = 'button';
                      String adDescription = ad['ad_description'];

                      return Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14.0),
                            child: Stack(
                              children: [
                                CachedNetworkImage(
                                  imageUrl: adImage,
                                  placeholder: (context, url) => Image.asset(
                                    'assets/images/vertical_placeholder.png',
                                    fit: BoxFit.cover,
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Image.asset(
                                    'assets/images/vertical_placeholder.png',
                                    fit: BoxFit.cover,
                                  ),
                                  width: MediaQuery.of(context).size.width - 32,
                                  height:
                                      (MediaQuery.of(context).size.width - 32) *
                                          9 /
                                          16,
                                  fit: BoxFit.cover,
                                ),
                                Container(
                                  // width: 200,
                                  height:
                                      (MediaQuery.of(context).size.width - 32) *
                                          9 /
                                          16,
                                  decoration: const BoxDecoration(
                                    // borderRadius: BorderRadius.circular(20.0),
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        Colors.black,
                                        Colors.transparent
                                      ],
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: whiteNormalText(adDescription),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(child: Container()),
                          GestureDetector(
                              onTap: () {
                                // Implement the logic to handle ad click
                                // For example, you can open the ad link.
                                _launchUrl(adLink);
                              },
                              child: ctaButton(adCta, context)),
                          Expanded(child: Container()),
                        ],
                      );
                    }).toList(),
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  addVerticalSpace(20),
                  Row(
                    children: [
                      blueBodyTextLarge(
                          language == 'ro' ? 'ACTIVITATE' : 'ACTIVITY'),
                    ],
                  ),
                  addVerticalSpace(120),
                  Container(
                    child: Center(
                      child: Text(
                        language == 'ro'
                            ? 'Vă rugăm să utilizați web-ul\npentru sarcini complexe de editare'
                            : 'Please use the web\nfor complex editing tasks',
                        style: GoogleFonts.quicksand(
                          fontSize: 14,
                          color: Colors.grey.withOpacity(.6),
                          fontWeight: FontWeight.bold,
                          letterSpacing: .5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url),
        mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }
}
