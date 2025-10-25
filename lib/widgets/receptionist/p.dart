import 'dart:convert';
import 'package:flutter/material.dart';

import '../../globals.dart' as globals;
import 'package:http/http.dart' as http;

class UserDetailsScreen extends StatefulWidget {
  @override
  _UserDetailsScreenState createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  TextEditingController _idController = TextEditingController(text: globals.userId);
  Map<String, TextEditingController> controllers = {};
  Map<String, bool> isEditing = {};
  Map<String, dynamic>? _userData;
  int? _statusCode;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
  }

  Future<void> fetchUserDetails(int id) async {
    try {
      final response = await http.post(
        Uri.parse(globals.host + '/receptionist/profileInfo'),
        headers: {
          'authorization': globals.token,
          'Content-Type': 'application/json'
        },
        body: json.encode({'idUser': id}),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as List<dynamic>;
        if (jsonData.isNotEmpty) {
          final userData = jsonData[0] as Map<String, dynamic>;
          setState(() {
            _statusCode = response.statusCode;
            _userData = {
              'id': userData['idKey'],
              'name': userData['name'],
              'Email': userData['email'],
              'password': userData['password'],
              'fullNumber': userData['number'],
              'Date': userData['date'],
              'addr': userData['address'],
            };

            controllers['name'] =
                TextEditingController(text: _userData!['name']);
            controllers['fullNumber'] =
                TextEditingController(text: _userData!['fullNumber']);
            controllers['Date'] =
                TextEditingController(text: _userData!['Date']);
            controllers['addr'] =
                TextEditingController(text: _userData!['addr']);

            isEditing['name'] = false;
            isEditing['fullNumber'] = false;
            isEditing['Date'] = false;
            isEditing['addr'] = false;

            _errorMessage = null;
          });

          print('User Data:');
          print('ID: ${_userData!['id']}');
          print('Name: ${_userData!['name']}');
          print('Email: ${_userData!['Email']}');
          print('Password: ${_userData!['password']}');
          print('Full Number: ${_userData!['fullNumber']}');
          print('Date: ${_userData!['Date']}');
          print('Address: ${_userData!['addr']}');
        } else {
          throw Exception('No user data found');
        }
      } else {
        setState(() {
          _userData = null;
          _errorMessage =
              'Failed to load user data. Status code: ${response.statusCode}';
        });
      }
    } catch (error) {
      print('Error: $error');
      setState(() {
        _userData = null;
        _errorMessage = 'An error occurred: $error';
      });
    }
  }

  Future<void> editUserProfile() async {
    try {
      final response = await http.post(
        Uri.parse(globals.host + '/receptionist/editProfileInfo'),
        headers: {
          'authorization': globals.token,
          'Content-Type': 'application/json'
        },
        body: json.encode({
          'idUser':
              _userData!['id'].toString(), // Ensure idUser is int
          'name': controllers['name']!.text,
          'fullNumber': controllers['fullNumber']!.text,
          'Date': controllers['Date']!.text,
          'addr': controllers['addr']!.text,
        }),
      );

      print('Edit Response status: ${response.statusCode}');
      print('Edit Response body: ${response.body}');

      if (response.statusCode == 200) {
        setState(() {
          _userData = {
            ..._userData!,
            'name': controllers['name']!.text,
            'fullNumber': controllers['fullNumber']!.text,
            'Date': controllers['Date']!.text,
            'addr': controllers['addr']!.text,
          };
          _statusCode = response.statusCode;
          _errorMessage = 'Profile updated successfully';

          // Print updated user data to console
          print('Updated User Data:');
          print('ID: ${_userData!['id']}');
          print('Name: ${_userData!['name']}');
          print('Full Number: ${_userData!['fullNumber']}');
          print('Date: ${_userData!['Date']}');
          print('Address: ${_userData!['addr']}');
        });
      } else {
        setState(() {
          _errorMessage =
              'Failed to update profile. Status code: ${response.statusCode}';
        });
      }
    } catch (error) {
      print('Error: $error');
      setState(() {
        _errorMessage = 'An error occurred: $error';
      });
    }
  }

  Widget buildEditableText(String key, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        isEditing[key]!
            ? Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: controllers[key],
                      decoration: InputDecoration(labelText: label),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.save),
                    onPressed: () {
                      setState(() {
                        editUserProfile();
                        isEditing[key] = false;
                        print('$label updated to: ${controllers[key]!.text}');
                      });
                    },
                  ),
                ],
              )
            : Row(
                children: [
                  Expanded(
                    child: Text(
                      controllers[key]!.text,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit,color: Colors.black,),
                    onPressed: () {
                      setState(() {
                        isEditing[key] = true;
                        print('Editing $label');
                      });
                    },
                  ),
                ],
              ),
        SizedBox(height: 16.0),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _idController,
              decoration: InputDecoration(labelText: 'Enter User ID'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final id = int.tryParse(_idController.text);
                if (id != null) {
                  fetchUserDetails(id);
                } else {
                  setState(() {
                    _errorMessage = 'Please enter a valid ID';
                  });
                }
              },
              child: Text('Fetch User Details'),
            ),
            SizedBox(height: 20),
            if (_statusCode != null) Text('Status Code: $_statusCode'),
            SizedBox(height: 20),
            if (_errorMessage != null)
              Text(_errorMessage!, style: TextStyle(color: Colors.red)),
            if (_userData != null)
              Expanded(
                child: ListView(
                  children: [
                    Text('ID: ${_userData!['id']}'),
                    buildEditableText('name', 'Name'),
                    buildEditableText('fullNumber', 'Full Number'),
                    buildEditableText('Date', 'Date'),
                    buildEditableText('addr', 'Address'),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
