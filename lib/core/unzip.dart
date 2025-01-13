import 'dart:io';
import 'package:archive/archive.dart';
import 'package:path_provider/path_provider.dart';

Future<void> unzipFile(String filePath) async {
    try {
      // Read the ZIP file
      final bytes = File(filePath).readAsBytesSync();
      final archive = ZipDecoder().decodeBytes(bytes);

      // Get the cache directory
      final cacheDir = await getTemporaryDirectory();

      // Clear previous file paths
    //   filePaths.clear();

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
            // filePaths.add(filePath);
          }
        }
      }

      // Update the UI
    //   setState(() {});
    } catch (e) {
      // Handle any errors that occur during unzipping
      print("Error unzipping file: $e");
    }
  }