import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';
import '../../globals.dart' as globals;

class AdddCampaignScreen extends StatefulWidget {
  @override
  _AdddCampaignScreenState createState() => _AdddCampaignScreenState();
}

class _AdddCampaignScreenState extends State<AdddCampaignScreen> {
  final _titleController = TextEditingController();
  final _budgetController = TextEditingController();
  final _targetGroupController = TextEditingController();
  final _reasonController = TextEditingController();
  final _descrController = TextEditingController();
  final _minimumDonationController = TextEditingController();

  XFile? _image;
  Uint8List? _webImage;
  bool _isLoading = false;

  final String uploadUrl = globals.host + '/superAdmin/addCampaigns';

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = pickedFile;
        if (kIsWeb) {
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
    if (_titleController.text.isEmpty ||
        _budgetController.text.isEmpty ||
        _targetGroupController.text.isEmpty ||
        _reasonController.text.isEmpty ||
        _descrController.text.isEmpty ||
        _minimumDonationController.text.isEmpty ||
        (_image == null && !kIsWeb)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please fill all fields and select an image.'),
      ));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
      Map<String, String> headers = {
        'authorization': globals.token,
      };
      request.headers.addAll(headers);
      request.fields['title'] = _titleController.text;
      request.fields['budget'] = _budgetController.text;
      request.fields['TargetGroup'] = _targetGroupController.text;
      request.fields['reason'] = _reasonController.text;
      request.fields['descr'] = _descrController.text;
      request.fields['minimumDonation'] = _minimumDonationController.text;

      if (_image != null) {
        if (kIsWeb) {
          request.files.add(http.MultipartFile.fromBytes(
            'image',
            _webImage!,
            filename: _image!.name,
            // contentType: MediaType('image', 'jpeg'),
          ));
        } else {
          var imageFile = File(_image!.path);
          var stream = http.ByteStream(imageFile.openRead());
          var length = await imageFile.length();

          request.files.add(http.MultipartFile(
            'image',
            stream,
            length,
            filename: _image!.name,
            contentType: MediaType('image', 'jpeg'),
          ));
        }
      }

      var response = await request.send();

      // Read the response and convert it to a string
      var responseBody = await response.stream.bytesToString();

      // Print the status code and response body to the console
      print('Status Code: ${response.statusCode}');
      print('Response Body: $responseBody');

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
    _budgetController.dispose();
    _targetGroupController.dispose();
    _reasonController.dispose();
    _descrController.dispose();
    _minimumDonationController.dispose();
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
        child: ListView(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _budgetController,
              decoration: InputDecoration(
                labelText: 'Budget',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _targetGroupController,
              decoration: InputDecoration(
                labelText: 'Target Group',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _reasonController,
              decoration: InputDecoration(
                labelText: 'Reason',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _descrController,
              decoration: InputDecoration(
                labelText: 'Description',
              ),
              maxLines: 3,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _minimumDonationController,
              decoration: InputDecoration(
                labelText: 'Minimum Donation',
              ),
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
                  Flexible(
                    child: kIsWeb
                        ? Image.memory(
                      _webImage!,
                      height: 50,
                      width: 50,
                      fit: BoxFit.cover,
                    )
                        : Image.file(
                      File(_image!.path),
                      height: 50,
                      width: 50,
                      fit: BoxFit.cover,
                    ),
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
