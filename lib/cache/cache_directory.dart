import 'dart:io';
import 'package:flutter/material.dart';
import 'package:onex/cache/directory_view.dart';
import 'package:path_provider/path_provider.dart';

class CacheDirectoryPage extends StatefulWidget {
  @override
  _CacheDirectoryPageState createState() => _CacheDirectoryPageState();
}

class _CacheDirectoryPageState extends State<CacheDirectoryPage> {
  List<FileSystemEntity> _files = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCacheFiles();
  }

  Future<void> _loadCacheFiles() async {
    final directory = await getTemporaryDirectory();
    final files = directory.listSync(); // List files synchronously
    setState(() {
      _files = files;
      _isLoading = false;
    });
  }

  Future<void> _clearCache() async {
    setState(() {
      _isLoading = true; // Show loading indicator
    });

    final cacheDir = await getTemporaryDirectory();
    try {
      if (cacheDir.existsSync()) {
        cacheDir.deleteSync(recursive: true);
      }
      // Reload the cache files after clearing
      await _loadCacheFiles();
    } catch (e) {
      print("Error clearing cache: $e");
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cache Directory'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _clearCache,
            tooltip: 'Clear Cache',
          ),
        ],
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DirectoryViewPage(path: file.path),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
