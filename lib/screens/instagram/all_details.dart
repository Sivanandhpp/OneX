import 'dart:convert';
import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:onex/global/theme_color.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class AllDetails extends StatefulWidget {
  @override
  _AllDetailsState createState() => _AllDetailsState();
}

class _AllDetailsState extends State<AllDetails>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic> followers = {};
  Map<String, dynamic> following = {};
  Map<String, dynamic> unfollowers = {};
  Map<String, dynamic> safelist = {};
  Map<String, dynamic> unfollowed = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    loadData();
  }

  Future<void> loadData() async {
    try {
      final directory = await getTemporaryDirectory();
      final instagramFolder = Directory('${directory.path}/instagram');

      final followersFile = File('${instagramFolder.path}/instafollowers.json');
      final followingFile = File('${instagramFolder.path}/instafollowing.json');
      final unfollowersFile =
          File('${instagramFolder.path}/instaunfollowers.json');
      final safelistFile = File('${instagramFolder.path}/instasafelist.json');
      final unfollowedFile =
          File('${instagramFolder.path}/instaunfollowed.json');

      if (followersFile.existsSync()) {
        followers = json.decode(await followersFile.readAsString());
      }
      if (followingFile.existsSync()) {
        following = json.decode(await followingFile.readAsString());
      }
      if (unfollowersFile.existsSync()) {
        unfollowers = json.decode(await unfollowersFile.readAsString());
      }
      if (safelistFile.existsSync()) {
        safelist = json.decode(await safelistFile.readAsString());
      }
      if (unfollowedFile.existsSync()) {
        unfollowed = json.decode(await unfollowedFile.readAsString());
      }
    } catch (e) {
      print('Error loading data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> updateJsonFile(
      String filename, Map<String, dynamic> data) async {
    try {
      final directory = await getTemporaryDirectory();
      final instagramFolder = Directory('${directory.path}/instagram');
      final file = File('${instagramFolder.path}/$filename');
      await file.writeAsString(json.encode(data));
    } catch (e) {
      print('Error updating $filename: $e');
    }
  }

  void handlePopupSelection(String value, String option) {
    setState(() {
      if (option == 'Safe List') {
        safelist[value] = unfollowers[value];
        unfollowers.remove(value);
        updateJsonFile('instasafelist.json', safelist);
      } else if (option == 'Unfollowed') {
        unfollowed[value] = unfollowers[value] ?? safelist[value];
        unfollowers.remove(value);
        safelist.remove(value);
        updateJsonFile('instaunfollowed.json', unfollowed);
        updateJsonFile('instasafelist.json', safelist);
      } else if (option == 'Remove from Safe List') {
        unfollowers[value] = safelist[value];
        safelist.remove(value);
        updateJsonFile('instasafelist.json', safelist);
      }
      updateJsonFile('instaunfollowers.json', unfollowers);
    });
  }

  Widget buildList(Map<String, dynamic> data, bool showPopup, bool isSafeList) {
    return ListView.builder(
      itemCount: data.keys.length,
      itemBuilder: (context, index) {
        final value = data.keys.elementAt(index);
        final tags =
            (data[value]?['tags'] as List<dynamic>? ?? []).cast<String>();

        return ListTile(
          leading: Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Text(
              "${index + 1}",
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: ThemeColor.primaryTextColor),
            ),
          ),
          title: Text(
            value,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: ThemeColor.primaryTextColor),
          ),
          subtitle: tags.isNotEmpty
              ? Wrap(
                  crossAxisAlignment: WrapCrossAlignment.start,
                  spacing: 6.0,
                  children: tags.map(
                    (tag) {
                      // ignore: unused_local_variable
                      Color tagColor = Color(0xFFFFFFFF);
                      const Color tagGreen = Color(0xFF008E36);
                      const Color tagRed = Color(0xFFFF0000);
                      if (tag == 'Recently Followed' || tag == 'Closefriends') {
                        tagColor = tagGreen;
                      } else if (tag == 'Restricted' || tag == 'Story hidden') {
                        tagColor = tagRed;
                      }
                      return Column(
                        children: [
                          SizedBox(
                            height: 5,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                                border: Border.all(color: tagColor, width: 2),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(20))),
                            child: Text(
                              tag,
                              style: TextStyle(
                                  color: tagColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      );
                    },
                  ).toList(),
                )
              : Container(),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.open_in_new),
                onPressed: () async {
                  final url = 'https://www.instagram.com/$value';
                  await launchUrl(
                    Uri.parse(url),
                    mode: LaunchMode.externalApplication,
                  );
                },
              ),
              showPopup && isSafeList
                  ? PopupMenuButton<String>(
                      onSelected: (option) =>
                          handlePopupSelection(value, option),
                      color: ThemeColor.primaryBlack,
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(20.0))),
                      menuPadding: EdgeInsets.only(left: 20),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'Remove from Safe List',
                          child: Text(
                            'Remove from SafeList',
                            style: GoogleFonts.ubuntu(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: ThemeColor.primaryTextColor),
                          ),
                        ),
                        PopupMenuItem(
                          value: 'Unfollowed',
                          child: Text(
                            'Add to Unfollowed',
                            style: GoogleFonts.ubuntu(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: ThemeColor.primaryTextColor),
                          ),
                        ),
                      ],
                    )
                  : showPopup
                      ? PopupMenuButton<String>(
                          onSelected: (option) =>
                              handlePopupSelection(value, option),
                          color: ThemeColor.primaryBlack,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20.0))),
                          menuPadding: EdgeInsets.only(left: 20),
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'Safe List',
                              child: Text(
                                'Add to SafeList',
                                style: GoogleFonts.ubuntu(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: ThemeColor.primaryTextColor),
                              ),
                            ),
                            PopupMenuItem(
                              value: 'Unfollowed',
                              child: Text(
                                'Add to Unfollowed',
                                style: GoogleFonts.ubuntu(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: ThemeColor.primaryTextColor),
                              ),
                            ),
                          ],
                        )
                      : Container(),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColor.scaffoldBgColor,
      appBar: AppBar(
        backgroundColor: ThemeColor.scaffoldBgColor,
        iconTheme: IconThemeData(color: ThemeColor.primaryTextColor),
        title: Text(
          "All Details",
          style: GoogleFonts.ubuntu(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ThemeColor.primaryTextColor),
        ),
        centerTitle: true,
        bottom: TabBar(
          isScrollable: true,
          indicatorColor: ThemeColor.primary,
          dragStartBehavior: DragStartBehavior.down,
          tabAlignment: TabAlignment.start,
          controller: _tabController,
          labelStyle: GoogleFonts.ubuntu(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: ThemeColor.primaryTextColor),
          tabs: [
            Tab(text: '${unfollowers.length} Unfollowers'),
            Tab(text: '${followers.length} Followers'),
            Tab(text: '${following.length} Following'),
            Tab(text: '${safelist.length} Safe List'),
            Tab(text: '${unfollowed.length} Unfollowed'),
          ],
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                buildList(unfollowers, true, false),
                buildList(followers, false, false),
                buildList(following, false, false),
                buildList(safelist, true, true),
                buildList(unfollowed, false, false),
              ],
            ),
    );
  }
}
