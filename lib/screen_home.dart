import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:archive/archive.dart';
import 'package:onex/CacheDirectoryPage.dart';
import 'package:onex/dashboard.dart';
import 'package:onex/instapic.dart';
import 'package:onex/unfollowedusers.dart';
import 'package:path_provider/path_provider.dart';

class ScreenHome extends StatefulWidget {
  const ScreenHome({super.key});

  @override
  State<ScreenHome> createState() => _ScreenHomeState();
}

class _ScreenHomeState extends State<ScreenHome> {
  List<String> _filePaths = [];

  Future<void> _pickAndUnzipFile() async {
    try {
      // Pick a ZIP file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip'],
      );

      if (result != null && result.files.isNotEmpty) {
        // Get the file path
        String filePath = result.files.single.path!;
        // Unzip the file
        await _unzipFile(filePath);
      }
    } catch (e) {
      // Handle any errors that occur during file picking
      print("Error picking file: $e");
    }
  }

  Future<void> _unzipFile(String filePath) async {
    try {
      // Read the ZIP file
      final bytes = File(filePath).readAsBytesSync();
      final archive = ZipDecoder().decodeBytes(bytes);

      // Get the cache directory
      final cacheDir = await getTemporaryDirectory();

      // Clear previous file paths
      _filePaths.clear();

      // Extract files and filter for JSON files
      for (final file in archive) {
        if (file.isFile) {
          // Check if the file name contains "followers" or "following"
          if (file.name.contains('followers_and_following')) {
            // Save the file to the cache directory
            final filePath =
                '${cacheDir.path}/instagram/${file.name.split('/').last}';

            final outFile = File(filePath);
            await outFile.create(recursive: true);
            await outFile.writeAsBytes(file.content as List<int>);

            // Add the file path to the list
            _filePaths.add(filePath);
          }
        }
      }

      // Update the UI
      setState(() {});
    } catch (e) {
      // Handle any errors that occur during unzipping
      print("Error unzipping file: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Zip File Unzipper'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => UnfollowedUsersScreen()),
                );
              },
              child: Text('Unfollowes'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Dashboard()),
                );
              },
              child: Text('Dashboard'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CacheDirectoryPage()),
                );
              },
              child: Text('View Cache Directory'),
            ),
            ElevatedButton(
              onPressed: _pickAndUnzipFile,
              child: Text('Select ZIP File'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _filePaths.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_filePaths[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
