import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:onex/global/theme_color.dart';
import 'package:path_provider/path_provider.dart';

class InstagramStatisticsScreen extends StatefulWidget {
  @override
  _InstagramStatisticsScreenState createState() =>
      _InstagramStatisticsScreenState();
}

class _InstagramStatisticsScreenState extends State<InstagramStatisticsScreen> {
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
          "Statitics",
          style: GoogleFonts.ubuntu(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ThemeColor.primaryTextColor),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildStatCard(
                      'Followers',
                      _statistics['total_followers'] ?? 0,
                      Colors.blue,
                    ),
                    _buildStatCard(
                      'Following',
                      _statistics['total_following'] ?? 0,
                      Colors.green,
                    ),
                    _buildStatCard(
                      'Unfollowers',
                      _statistics['total_unfollowers'] ?? 0,
                      Colors.red,
                    ),
                    _buildStatCard(
                      'Close Friends',
                      _statistics['total_close_friends'] ?? 0,
                      Colors.orange,
                    ),
                    _buildStatCard(
                      'Restricted Accounts',
                      _statistics['total_restricted'] ?? 0,
                      Colors.purple,
                    ),
                    _buildStatCard(
                      'Pending Requests Sent',
                      _statistics['pending_follow_requests'] ?? 0,
                      Colors.brown,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatCard(String title, int count, Color color) {
    return Card(
      color: ThemeColor.primaryBlack,
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: ListTile(
        leading: Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 18.0,
            color: ThemeColor.lightGrey,
            fontWeight: FontWeight.bold,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18.0,
            color: ThemeColor.lightGrey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
