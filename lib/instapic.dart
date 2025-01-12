import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class InstagramProfilePicture extends StatefulWidget {
  final String username;

  InstagramProfilePicture({required this.username});

  @override
  _InstagramProfilePictureState createState() => _InstagramProfilePictureState();
}

class _InstagramProfilePictureState extends State<InstagramProfilePicture> {
  String imageUrl = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchInstagramProfileImage();
  }

  Future<void> fetchInstagramProfileImage() async {
    final response = await http.get(Uri.parse('https://www.instagram.com/${widget.username}/?__a=1'));

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      var userProfile = data['graphql']['user']['profile_pic_url_hd'];
      setState(() {
        imageUrl = userProfile;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
        imageUrl = ''; // Handle error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Instagram Profile Picture')),
      body: Center(
        child: isLoading
            ? CircularProgressIndicator()
            : imageUrl.isNotEmpty
                ? Image.network(imageUrl)
                : Text('Error fetching image'),
      ),
    );
  }
}
