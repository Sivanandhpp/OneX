import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

class UnfollowedUsersScreen extends StatefulWidget {
  @override
  _UnfollowedUsersScreenState createState() => _UnfollowedUsersScreenState();
}

class _UnfollowedUsersScreenState extends State<UnfollowedUsersScreen> {
  List<Map<String, String>> _unfollowedUsers = [];
  List<Map<String, String>> _safeList = [];
  List<Map<String, String>> _followers = [];
  List<Map<String, String>> _following = [];
  Map<String, List<String>> _userTags = {};

  int _itemsPerPage = 30;
  int _currentPage = 0;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  int _totalFollowers = 0;
  int _totalFollowing = 0;
  int _totalunfollowers = 0;

  @override
  void initState() {
    super.initState();
    _loadAndCompareData();
  }

  Future<void> _loadAndCompareData() async {
    try {
      // Get the path to the cache directory
      final directory = await getTemporaryDirectory();
      final instagramFolder = Directory('${directory.path}/instagram');

      // Load all followers files and the following file from the cache directory
      final followingFile = File('${instagramFolder.path}/following.json');

      if (!followingFile.existsSync()) {
        throw Exception('Following file not found in cache/instagram folder.');
      }

      final followersFiles = instagramFolder
          .listSync()
          .where((file) =>
              file.path.contains('followers_') && file.path.endsWith('.json'))
          .toList();

      if (followersFiles.isEmpty) {
        throw Exception('No followers files found in cache/instagram folder.');
      }

      Set<String> followersValues = {};

      for (var file in followersFiles) {
        String followersJson = await File(file.path).readAsString();
        List<dynamic> followersList = json.decode(followersJson);
        followersValues.addAll(
          followersList
              .map((f) => f['string_list_data'][0]['value'] as String)
              .toSet(),
        );
        _followers.addAll(followersList.map((f) => {
              'value': f['string_list_data'][0]['value'] as String,
              'href': f['string_list_data'][0]['href'] as String,
            }));
      }

      _totalFollowers = followersValues.length;

      String followingJson = await followingFile.readAsString();
      List<dynamic> followingList =
          json.decode(followingJson)['relationships_following'];

      _totalFollowing = followingList.length;

      _following.addAll(followingList.map((f) => {
            'value': f['string_list_data'][0]['value'] as String,
            'href': f['string_list_data'][0]['href'] as String,
          }));

      // Find users in "following" but not in "followers"
      List<Map<String, String>> unfollowedUsers = followingList
          .where((f) =>
              !followersValues.contains(f['string_list_data'][0]['value']))
          .map((f) => {
                'value': f['string_list_data'][0]['value'] as String,
                'href': f['string_list_data'][0]['href'] as String,
              })
          .toList();

      // Load additional files and mark tags
      final additionalFiles = [
        'close_friends.json',
        'hide_story.json',
        'restricted_profiles.json',
        'recent_follow_requests.json'
      ];

      for (String fileName in additionalFiles) {
        final file = File('${instagramFolder.path}/$fileName');
        if (file.existsSync()) {
          String fileJson = await file.readAsString();
          Map<String, dynamic> fileMap = json.decode(fileJson);
          String key = fileMap.keys.firstWhere(
              (k) => k.startsWith('relationships_'),
              orElse: () => '');

          if (key.isNotEmpty) {
            List<dynamic> fileList = fileMap[key];
            for (var entry in fileList) {
              final username = entry['string_list_data'][0]['value'] as String;
              String tag =
                  fileName.replaceAll('.json', '').replaceAll('_', ' ');
              if (fileName == "close_friends.json") {
                tag = "Closefriend";
              } else if (fileName == "recent_follow_requests.json") {
                tag = "Recently Followed";
              } else if (fileName == "hide_story.json") {
                tag = "Story hidden";
              } else if (fileName == "restricted_profiles.json") {
                tag = "Restricted";
              }

              if (_userTags[username] == null) {
                _userTags[username] = [];
              }
              _userTags[username]!.add(tag);
            }
          }
        }
      }

      setState(() {
        _unfollowedUsers = List<Map<String, String>>.from(unfollowedUsers);
        _totalunfollowers = _unfollowedUsers.length;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading or parsing JSON: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Instagram Manager',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
          ),
          bottom: TabBar(
            tabs: [
              Tab(text: '$_totalFollowers Followers'),
              Tab(text: '$_totalFollowing Following'),
              Tab(text: '$_totalunfollowers Unfollowers'),
            ],
          ),
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildListView(_followers, 'Followers'),
                  _buildListView(_following, 'Following'),
                  _buildListView(_unfollowedUsers, 'Unfollowers',
                      isUnfollowed: true),
                ],
              ),
      ),
    );
  }

  Widget _buildListView(List<Map<String, String>> users, String type,
      {bool isUnfollowed = false}) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (!_isLoadingMore &&
            scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
          _loadMore();
        }
        return true;
      },
      child: ListView.builder(
        itemCount: ((_currentPage + 1) * _itemsPerPage <= users.length
            ? (_currentPage + 1) * _itemsPerPage
            : users.length),
        itemBuilder: (context, index) {
          final user = users[index];
          final tags = _userTags[user['value']] ?? [];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: Text(
                  "${index + 1}",
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                ),
                title: Text(
                  user['value']!,
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                ),
                subtitle: tags.isNotEmpty
                    ? Wrap(
                        crossAxisAlignment: WrapCrossAlignment.start,
                        spacing: 6.0,
                        children: tags.map(
                          (tag) {
                            const Color __green = Color(0xFF008E36);
                            const Color __red = Color(0xFFFF0000);
                            Color __color = Color(0xFF000000);
                            if (tag == 'Recently Followed' ||
                                tag == 'Closefriends') {
                              __color = __green;
                            } else if (tag == 'Restricted' ||
                                tag == 'Story hidden') {
                              __color = __red;
                            } else if (tag == '') {}
                            return Column(
                              children: [
                                SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                      border:
                                          Border.all(color: __color, width: 2),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(20))),
                                  child: Text(
                                    tag,
                                    style: TextStyle(
                                        color: __color,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            );
                          },
                          // Chip(
                          //       label: Text(tag),
                          //       backgroundColor: Colors.blue.shade100,
                          //     )
                        ).toList(),
                      )
                    : Container(),
                trailing: TextButton(
                  onPressed: () async {
                    await _launchURL(user['href']!, user['value']!);
                    _showActionDialog(user);
                  },
                  child: Text('View Profile'),
                ),
              ),
              // if (tags.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Divider(),
              ),
            ],
          );
        },
      ),
    );
  }

  void _loadMore() {
    setState(() {
      _isLoadingMore = true;
    });

    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        _currentPage++;
        _isLoadingMore = false;
      });
    });
  }

  Future<void> _launchURL(String url, String instaID) async {
    // final Uri uri = Uri.parse(url);

    // if (await canLaunchUrl(uri)) {
    //   await launchUrl(
    //     uri,
    //     mode: LaunchMode.platformDefault,
    //   );
    // } else {
    //   throw 'Could not launch $url';
    // }

    var nativeUrl = "instagram://user?username=$instaID";

    try {
      await launchUrlString(nativeUrl, mode: LaunchMode.externalApplication);
    } catch (e) {
      print(e);
      await launchUrlString(url, mode: LaunchMode.platformDefault);
    }
  }

  void _showActionDialog(Map<String, String> user) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Profile Action'),
          content: Text('What would you like to do?'),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _unfollowedUsers.remove(user);
                  _safeList.add(user);
                });
                Navigator.pop(context);
              },
              child: Text('Add to Safe List'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _unfollowedUsers.remove(user);
                });
                Navigator.pop(context);
              },
              child: Text('Unfollowed'),
            ),
          ],
        );
      },
    );
  }
}
