import 'dart:typed_data';
import 'dart:html'; // Only works in Flutter web

import 'package:flutter/material.dart';
import '../../globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'dart:convert'; // Required to decode JSON data

class UploadImageScreen extends StatefulWidget {
  final int id;

  UploadImageScreen({required this.id});

  @override
  _UploadImageScreenState createState() => _UploadImageScreenState();
}

class _UploadImageScreenState extends State<UploadImageScreen> {
  List<Uint8List>? _images;
  bool _isUploading = false;
  String? _uploadError;
  List<Map<String, dynamic>> documents = []; // Store fetched documents

  @override
  void initState() {
    super.initState();
    _fetchDocuments(); // Fetch documents when the screen is initialized
  }

  Future<void> _fetchDocuments() async {
    try {
      final response = await http.get(
        Uri.parse(globals.host + '/visitedTeam/showDocument'),
        headers: {
          'authorization': globals.token,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          documents = List<Map<String, dynamic>>.from(json.decode(response.body));
        });
      } else {
        print('Failed to load documents. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching documents: $e');
    }
  }

  Future<void> _pickImages() async {
    FileUploadInputElement uploadInput = FileUploadInputElement();
    uploadInput.accept = 'image/*';
    uploadInput.multiple = true; // Allow multiple file selection
    uploadInput.click();

    uploadInput.onChange.listen((event) {
      final files = uploadInput.files;
      if (files != null && files.isNotEmpty) {
        List<Uint8List> imagesData = [];
        print('Files picked: ${files.length}');

        for (var file in files) {
          final reader = FileReader();
          reader.readAsArrayBuffer(file);
          reader.onLoadEnd.listen((e) {
            setState(() {
              imagesData.add(reader.result as Uint8List);
              _images = imagesData;
              _uploadError = null;
            });
            print('File read: ${file.name}');
          });
          reader.onError.listen((fileEvent) {
            setState(() {
              _uploadError = 'Error reading file: ${file.name}';
            });
            print('Error reading file: ${file.name}');
          });
        }
      }
    });
  }

  Future<void> _uploadImages() async {
    if (_images == null || _images!.isEmpty) return;

    setState(() {
      _isUploading = true;
      _uploadError = null;
    });

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(globals.host + '/visitedTeam/uploadImages'),
      );
      request.fields['idRequest'] = widget.id.toString(); // Pass the actual ID
      Map<String, String> headers = { 'authorization': globals.token,};
      request.headers.addAll(headers);

      for (var image in _images!) {
        var multipartFile = http.MultipartFile.fromBytes(
          'images',
          image,
          filename: 'upload_image_${DateTime.now().millisecondsSinceEpoch}.jpg', // Unique filename
        );
        request.files.add(multipartFile);
        print('Added image to request: ${multipartFile.filename}');
      }

      var response = await request.send();
      if (response.statusCode == 200) {
        print('Uploaded successfully');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Images uploaded successfully!'),
        ));
      } else {
        setState(() {
          _uploadError = 'Failed to upload. Server responded with status code ${response.statusCode}.';
        });
        print('Failed to upload. Server responded with status code ${response.statusCode}.');
      }
    } catch (e) {
      setState(() {
        _uploadError = 'Failed to upload: $e';
      });
      print('Failed to upload: $e');
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Images'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (documents.isNotEmpty) ...[
                Text(
                  'Documents',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    final doc = documents[index];
                    return ListTile(
                      title: Text(doc['title']),
                     // subtitle: Text('Date: ${doc['dayDate']}'),
                    );
                  },
                ),
                SizedBox(height: 20),
              ],
              ElevatedButton(
                onPressed: _pickImages,
                child: Text('Pick Images'),
              ),
              SizedBox(height: 20),
              _images != null
                  ? Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _images!.map((image) {
                  return Image.memory(
                    image,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  );
                }).toList(),
              )
                  : Text('No images selected'),
              SizedBox(height: 20),
              _isUploading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _uploadImages,
                child: Text('Upload Images'),
              ),
              if (_uploadError != null) ...[
                SizedBox(height: 20),
                Text(
                  _uploadError!,
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
