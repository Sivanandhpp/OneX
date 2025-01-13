import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<Map<String, int>> processInstagramData() async {
  try {
    // Get the path to the cache directory
    final directory = await getTemporaryDirectory();
    final instagramFolder = Directory('${directory.path}/instagram');

    // Collect followers data
    final followersFiles = instagramFolder
        .listSync()
        .where((file) =>
            file.path.contains('followers_') && file.path.endsWith('.json'))
        .toList();
    Map<String, Map<String, List<String>>> followersData = {};

    for (var file in followersFiles) {
      String followersJson = await File(file.path).readAsString();
      List<dynamic> followersList = json.decode(followersJson);

      for (var entry in followersList) {
        String value = entry['string_list_data'][0]['value'];
        followersData[value] = {'tags': []};
      }
    }

    // Collect following data
    final followingFile = File('${instagramFolder.path}/following.json');
    if (!followingFile.existsSync()) {
      throw Exception('Following file not found.');
    }

    String followingJson = await followingFile.readAsString();
    List<dynamic> followingList =
        json.decode(followingJson)['relationships_following'];

    Map<String, Map<String, List<String>>> followingData = {};
    for (var entry in followingList) {
      String value = entry['string_list_data'][0]['value'];
      followingData[value] = {'tags': []};
    }

    // Find unfollowers
    Map<String, Map<String, List<String>>> unfollowersData = {};
    followingData.forEach((key, _) {
      if (!followersData.containsKey(key)) {
        unfollowersData[key] = {'tags': []};
      }
    });

    // Load additional files and assign tags
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
            String value = entry['string_list_data'][0]['value'];
            String tag = '';
            // .replaceAll('.json', '')
            // .replaceAll('_', ' ')
            // .split(' ')
            // .map((word) => word[0].toUpperCase() + word.substring(1))
            // .join(' ');
            if (fileName == 'close_friends.json') {
              tag = 'Closefriends';
            } else if (fileName == 'hide_story.json') {
              tag = 'Story hidden';
            } else if (fileName == 'restricted_profiles.json') {
              tag = 'Restricted';
            } else if (fileName == 'recent_follow_requests.json') {
              tag = 'Recently Followed';
            }

            if (followersData.containsKey(value)) {
              followersData[value]!['tags']!.add(tag);
            }
            if (followingData.containsKey(value)) {
              followingData[value]!['tags']!.add(tag);
            }
            if (unfollowersData.containsKey(value)) {
              unfollowersData[value]!['tags']!.add(tag);
            }
          }
        }
      }
    }

    // Process pending follow requests
    final pendingFollowRequestsFile =
        File('${instagramFolder.path}/pending_follow_requests.json');
    int pendingFollowRequestsCount = 0;

    if (pendingFollowRequestsFile.existsSync()) {
      String pendingJson = await pendingFollowRequestsFile.readAsString();
      Map<String, dynamic> pendingMap = json.decode(pendingJson);
      String key = pendingMap.keys.firstWhere(
          (k) => k.startsWith('relationships_follow_requests_sent'),
          orElse: () => '');

      if (key.isNotEmpty) {
        List<dynamic> pendingList = pendingMap[key];
        pendingFollowRequestsCount = pendingList.length;
      }
    }

    // Save statistics
    Map<String, int> details = {
      'total_followers': followersData.length,
      'total_following': followingData.length,
      'total_unfollowers': unfollowersData.length,
      'total_close_friends': followersData.values
          .where((v) => v['tags']!.contains('Close Friends'))
          .length,
      'total_restricted': followersData.values
          .where((v) => v['tags']!.contains('Restricted Profiles'))
          .length,
      'pending_follow_requests': pendingFollowRequestsCount,
    };

    // Save followers, following, unfollowers data and details as JOSN
    File('${instagramFolder.path}/instafollowers.json')
        .writeAsString(json.encode(followersData));
    File('${instagramFolder.path}/instafollowing.json')
        .writeAsString(json.encode(followingData));
    File('${instagramFolder.path}/instaunfollowers.json')
        .writeAsString(json.encode(unfollowersData));
    File('${instagramFolder.path}/instadetails.json')
        .writeAsString(json.encode(details));

    return details;
  } catch (e) {
    print('Error processing Instagram data: $e');
    return {};
  }
 
}
