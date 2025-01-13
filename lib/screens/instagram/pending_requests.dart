import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:onex/global/theme_color.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class PendingFollowRequestsScreen extends StatefulWidget {
  @override
  _PendingFollowRequestsScreenState createState() =>
      _PendingFollowRequestsScreenState();
}

class _PendingFollowRequestsScreenState
    extends State<PendingFollowRequestsScreen> {
  List<String> pendingRequests = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadPendingRequests();
  }

  Future<void> loadPendingRequests() async {
    try {
      final directory = await getTemporaryDirectory();
      final instagramFolder = Directory('${directory.path}/instagram');
      final pendingFile =
          File('${instagramFolder.path}/pending_follow_requests.json');

      if (pendingFile.existsSync()) {
        String pendingJson = await pendingFile.readAsString();
        Map<String, dynamic> pendingMap = json.decode(pendingJson);

        String key = pendingMap.keys.firstWhere(
            (k) => k.startsWith('relationships_follow_requests_sent'),
            orElse: () => '');

        if (key.isNotEmpty) {
          List<dynamic> pendingList = pendingMap[key];
          pendingRequests = pendingList
              .map((entry) => entry['string_list_data'][0]['value'] as String)
              .toList();
        }
      }
    } catch (e) {
      print('Error loading pending requests: $e');
    } finally {
      setState(() {
        isLoading = false;
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
          "Requests sent",
          style: GoogleFonts.ubuntu(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ThemeColor.primaryTextColor),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: pendingRequests.length,
              itemBuilder: (context, index) {
                final username = pendingRequests[index];
                return Column(
                  children: [
                    ListTile(
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
                        username,
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: ThemeColor.primaryTextColor),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.open_in_new),
                        onPressed: () async {
                          final url = 'https://www.instagram.com/$username';
                          await launchUrl(
                            Uri.parse(url),
                            mode: LaunchMode.externalApplication,
                          );
                        },
                      ),
                      minTileHeight: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Divider(
                        thickness: 0.2,
                        color: ThemeColor.grey,
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
