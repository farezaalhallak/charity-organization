import 'dart:convert';
import 'package:flutter/material.dart';

import '../../globals.dart' as globals;
import 'package:http/http.dart' as http;

class ProfileInfoScreen extends StatefulWidget {
  @override
  _ProfileInfoScreenState createState() => _ProfileInfoScreenState();
}

class _ProfileInfoScreenState extends State<ProfileInfoScreen> {
  final _idController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _profileInfo; // Variable to store the profile info

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  Future<void> fetchProfileInfo() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _profileInfo = null; // Reset the profile info
    });

    final url = Uri.parse(globals.host + '/superAdmin/profileInfo');
    final id = _idController.text.trim();

    print('Entered ID: $id');

    try {
      final response = await http.post(
        url,
        body: json.encode({'id': id}),
        headers: {
          'authorization': globals.token,
          'Content-Type': 'application/json'
        },
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      // Check response status
      if (response.statusCode != 200) {
        throw Exception(
            'Failed to fetch profile info. Status Code: ${response.statusCode}');
      }

      // Decode response
      dynamic jsonResponse = json.decode(response.body);

      if (jsonResponse is List) {
        // Handle the case where jsonResponse is a List (array of profiles)
        if (jsonResponse.isEmpty) {
          throw Exception('Empty list received.');
        } else {
          // Assuming you want to display the first profile from the array
          setState(() {
            _profileInfo = jsonResponse[0];
            _isLoading = false;
          });
        }
      } else if (jsonResponse is Map<String, dynamic>) {
        // Handle the case where jsonResponse is a Map (single profile)
        setState(() {
          _profileInfo = jsonResponse;
          _isLoading = false;
        });
      } else {
        throw Exception('Invalid response format.');
      }
    } catch (e) {
      print('Error fetching profile info: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Error fetching profile info';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the width of the screen
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Info'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _idController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter ID key',
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: fetchProfileInfo,
              child: Text('Fetch Profile Info'),
            ),
            SizedBox(height: 16),
            if (_isLoading)
              Center(child: CircularProgressIndicator())
            else if (_errorMessage != null)
              Text('Error: $_errorMessage', style: TextStyle(color: Colors.red))
            else if (_profileInfo != null) ...[
              SizedBox(height: 16),
              Container(
                width: screenWidth, // Set width to screenWidth
                child: Card(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ID: ${_profileInfo!['id']}',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Text('Name: ${_profileInfo!['name']}'),
                        SizedBox(height: 8),
                        Text('Email: ${_profileInfo!['email']}'),
                        SizedBox(height: 8),
                        Text('Full Number: ${_profileInfo!['fullnumber']}'),
                        SizedBox(height: 8),
                        Text('Address: ${_profileInfo!['address']}'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
