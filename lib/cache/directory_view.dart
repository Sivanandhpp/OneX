import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class DirectoryViewPage extends StatefulWidget {
  final String path;

  DirectoryViewPage({required this.path});

  @override
  _DirectoryViewPageState createState() => _DirectoryViewPageState();
}

class _DirectoryViewPageState extends State<DirectoryViewPage> {
  List<FileSystemEntity> _files = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    final directory = Directory(widget.path);
    final files = directory.listSync(); // List files synchronously
    setState(() {
      _files = files;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Directory: ${widget.path.split('/').last}'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _files.isEmpty
              ? Center(child: Text('No files found.'))
              : ListView.builder(
                  itemCount: _files.length,
                  itemBuilder: (context, index) {
                    final file = _files[index];
                    return ListTile(
                      title: Text(file.path.split('/').last),
                      subtitle: Text(file.statSync().modified.toString()),
                      onTap: () {
                        if (file is Directory) {
                          // Navigate to the directory
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  DirectoryViewPage(path: file.path),
                            ),
                          );
                        } else {
                          // Handle file tap (e.g., open the file or show details)
                          // You can implement file opening logic here
                        }
                      },
                    );
                  },
                ),
    );
  }
}
