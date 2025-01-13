import 'package:file_picker/file_picker.dart';

Future<String> pickFile() async {
  String filePath = 'null';
  try {
    // Pick a ZIP file
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: false,

      allowedExtensions: ['zip'],
    );

    if (result != null && result.files.isNotEmpty) {
      // Get the file path
      filePath = result.files.single.path!;
      
      // Unzip the file
      return filePath;
    } 
  } catch (e) {
    // Handle any errors that occur during file picking
    print("Error picking file: $e");
  }
  return filePath;
}
 