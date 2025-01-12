import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

Future<FilePickerResult?> filepicker(
    String filetype, BuildContext context) async {
  return await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: [filetype],
  );
}
