import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:onex/cache/cache_directory.dart';
import 'package:onex/core/filepicker.dart';
import 'package:onex/core/instadata.dart';
import 'package:onex/core/unzip.dart';
import 'package:onex/global/theme_color.dart';
import 'package:onex/screens/instagram/all_details.dart';
import 'package:onex/screens/instagram/unfollowers.dart';
import 'package:onex/screens/instagram/pending_requests.dart';
import 'package:onex/statitics.dart';
import 'package:onex/widgets/show_snackbar.dart';
import 'package:path_provider/path_provider.dart';

class InstagramOptions extends StatefulWidget {
  const InstagramOptions({super.key});

  @override
  State<InstagramOptions> createState() => _InstagramOptionsState();
}

class _InstagramOptionsState extends State<InstagramOptions> {
  String fileName = "Upload your data from Instagram here";
  Map<String, int> details = {};
  Map<String, int> _statistics = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    try {
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/instagram/instadetails.json');

      if (file.existsSync()) {
        final jsonData = await file.readAsString();
        setState(() {
          _statistics = Map<String, int>.from(json.decode(jsonData));
          _isLoading = false;
        });
      } else {
        setState(() {
          _statistics = {
            'total_followers': 0,
            'total_following': 0,
            'total_unfollowers': 0,
            'total_close_friends': 0,
            'total_restricted': 0,
            'pending_follow_requests': 0,
          };
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading statistics: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColor.scaffoldBgColor,
      appBar: AppBar(
        backgroundColor: ThemeColor.scaffoldBgColor,
        iconTheme: IconThemeData(color: ThemeColor.primaryTextColor),
        title: Text(
          "Instagram Options",
          style: GoogleFonts.ubuntu(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ThemeColor.primaryTextColor),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => InstagramStatisticsScreen()),
                );
              },
              child: Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: <Color>[
                        const Color(0xFFFAFF16),
                        const Color(0xFF8B62FF),
                      ],
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(32))),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "${_statistics['total_followers'] ?? 0}",
                                style: GoogleFonts.ubuntu(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: ThemeColor.primaryBlack),
                              ),
                              Text(
                                "Followers",
                                style: GoogleFonts.ubuntu(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    color: ThemeColor.primaryBlack),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "${_statistics['total_following'] ?? 0}",
                                style: GoogleFonts.ubuntu(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: ThemeColor.primaryBlack),
                              ),
                              Text(
                                "Following",
                                style: GoogleFonts.ubuntu(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    color: ThemeColor.primaryBlack),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "${_statistics['total_unfollowers'] ?? 0}",
                                style: GoogleFonts.ubuntu(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: ThemeColor.primaryBlack),
                              ),
                              Text(
                                "Unfollowers",
                                style: GoogleFonts.ubuntu(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    color: ThemeColor.primaryBlack),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: GestureDetector(
                              onTap: () {
                                pickFile().then((value) async {
                                  if (value == 'null') {
                                    // ignore: use_build_context_synchronously
                                    showSnackbar(
                                        context, "No ZIP File Selected");
                                  } else {
                                    setState(() {
                                      fileName = value.split('/').last;
                                    });
                                    await unzipFile(value).then(
                                      (value) async {
                                        details = await processInstagramData().whenComplete(() {
                                           _loadStatistics();
                                        },);
                                      },
                                    );
                                  }
                                });
                              },
                              child: Container(
                                height: 40,
                                decoration: BoxDecoration(
                                    color: ThemeColor.primaryBlack,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(15))),
                                child: Center(
                                  child: Text(
                                    "Upload new ZIP",
                                    style: GoogleFonts.ubuntu(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: ThemeColor.primaryTextColor),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Expanded(
                            flex: 1,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          CacheDirectoryPage()),
                                );
                              },
                              child: Container(
                                height: 40,
                                decoration: BoxDecoration(
                                    color: ThemeColor.primaryBlack,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(15))),
                                child: Center(
                                  child: Text(
                                    "Select from recent",
                                    style: GoogleFonts.ubuntu(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: ThemeColor.primaryTextColor),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Explore Instagram Options!",
                  style: GoogleFonts.ubuntu(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: ThemeColor.primaryTextColor),
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => InstaUnfollowers()),
                          );
                        },
                        child: Container(
                          height: 80,
                          decoration: BoxDecoration(
                              color: ThemeColor.primaryTextColor,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(32))),
                          child: Center(
                            child: Text(
                              "Unfollowers",
                              style: GoogleFonts.ubuntu(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: ThemeColor.secondaryTextColor),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    PendingFollowRequestsScreen()),
                          );
                        },
                        child: Container(
                          height: 80,
                          decoration: BoxDecoration(
                              color: ThemeColor.red,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(32))),
                          child: Center(
                            child: Text(
                              "Pending Req Sent",
                              style: GoogleFonts.ubuntu(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: ThemeColor.primaryTextColor),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 8,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AllDetails()),
                    );
                  },
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                        color: ThemeColor.lightGrey,
                        borderRadius: BorderRadius.all(Radius.circular(32))),
                    child: Center(
                      child: Text(
                        "All Details",
                        style: GoogleFonts.ubuntu(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: ThemeColor.secondaryTextColor),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
