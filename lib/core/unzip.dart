// import 'dart:io';

// import 'package:archive/archive.dart';
// import 'package:file_picker/file_picker.dart';

// void _unzipFile(FilePickerResult result) {
     
//       // Get the file path
//       String filePath = result.files.single.path!;
//       // Unzip the file
//       // Read the ZIP file
//     final bytes = File(filePath).readAsBytesSync();
//     final archive = ZipDecoder().decodeBytes(bytes);

//     // Clear previous file names
//     _fileNames.clear();

//     // Extract file names
//     for (final file in archive) {
//       _fileNames.add(file.name);
//     }


    
//     // // Update the UI
//     // setState(() {});
//   }