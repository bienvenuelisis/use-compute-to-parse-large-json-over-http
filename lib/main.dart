import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class EmptyObject {
  const EmptyObject();

  factory EmptyObject.fromJson(Map<String, dynamic> json) {
    return const EmptyObject();
  }
}

List<EmptyObject> _parseJsonContent(String encodedJson) {
  final List<dynamic> jsonDecoded = jsonDecode(encodedJson);
  return jsonDecoded.map((json) => EmptyObject.fromJson(json)).toList();
}

class _MainAppState extends State<MainApp> {
  int? _fileSize;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    //_parseLargeJsonFileInMainThread();
  }

  Future<void> _parseLargeJsonFile(Function(String) parser) async {
    setState(() {
      _fileSize = null;
      _loading = true;
    });

    final response = await http.get(
      Uri.https(
        'raw.githubusercontent.com',
        '/json-iterator/test-data/master/large-file.json',
      ),
    );

    await parser(response.body);

    setState(() {
      _fileSize = response.contentLength;
      _loading = false;
    });
  }

  Future<void> _parseLargeJsonFileInBackground() async {
    _parseLargeJsonFile(
      (String json) => compute(_parseJsonContent, json),
    );
  }

  Future<void> _parseLargeJsonFileInMainThread() async {
    _parseLargeJsonFile(
      (String encodedJson) => _parseJsonContent(encodedJson),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: _loading
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_fileSize != null)
                      Text(
                        'Parsed json file size: ${(_fileSize! / (1024 * 1024)).round()} MB',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    TextButton(
                      onPressed: _parseLargeJsonFileInMainThread,
                      child: const Text('Download and parse large json file'),
                    ),
                    TextButton(
                      onPressed: _parseLargeJsonFileInBackground,
                      child: const Text(
                        'Download and parse large json file using compute',
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
