import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

import '../../globals.dart' as globals;
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; // Import http_parser for MediaType
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data'; // For handling image files on the web

class AddCampaignScreen extends StatefulWidget {
  @override
  _AddCampaignScreenState createState() => _AddCampaignScreenState();
}

class _AddCampaignScreenState extends State<AddCampaignScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  XFile? _image;
  Uint8List? _webImage;
  bool _isLoading = false;

  final String uploadUrl = globals.host + '/mediaTeam/addPreviousCampaigns';

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = pickedFile;
        if (kIsWeb) {
          // Load the image as Uint8List for web usage
          pickedFile.readAsBytes().then((bytes) {
            setState(() {
              _webImage = bytes;
            });
          });
        }
      });
    }
  }

  Future<void> _addCampaign() async {
    if (_titleController.text.isEmpty || (_image == null && !kIsWeb)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please enter a title and select an image.'),
      ));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      Map<String, String> headers = { 'authorization': globals.token,};

      var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));

      request.headers.addAll(headers);

      request.fields['title'] = _titleController.text;
      request.fields['descr'] = _descriptionController.text;

      if (_image != null) {
        if (kIsWeb) {
          // Add image file as Byte for web
          request.files.add(http.MultipartFile.fromBytes(
            'image',
            _webImage!,
            filename: _image!.name,
            contentType: MediaType(
                'image', 'jpeg'), // Adjust according to your image type
          ));
        } else {
          // Add image file path for non-web
          var imageFile = File(_image!.path);
          var stream = http.ByteStream(imageFile.openRead());
          var length = await imageFile.length();

          request.files.add(http.MultipartFile(
            'image',
            stream,
            length,
            filename: _image!.name,
            contentType: MediaType(
                'image', 'jpeg'), // Adjust according to your image type
          ));
        }
      }

      var response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Campaign added successfully!'),
        ));
        Navigator.pop(context, true); // Return true to indicate success
      } else {
        throw Exception('Failed to add campaign');
      }
    } catch (e) {
      print('Error adding campaign: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error adding campaign: $e'),
      ));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Campaign'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
              ),
              maxLines: 3,
            ),
            SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _pickImage,
                  child: Text('Pick Image'),
                ),
                SizedBox(width: 16),
                if (_image != null)
                  kIsWeb
                      ? Image.memory(
                          _webImage!,
                          height: 100,
                          width: 100,
                        )
                      : Image.file(
                          File(_image!.path),
                          height: 100,
                          width: 100,
                        ),
              ],
            ),
            SizedBox(height: 24),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _addCampaign,
                    child: Text('Add Campaign'),
                  ),
          ],
        ),
      ),
    );
  }
}
