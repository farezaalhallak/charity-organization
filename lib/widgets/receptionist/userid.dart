import 'dart:convert';
import 'package:flutter/material.dart';

import '../../globals.dart' as globals;
import 'package:http/http.dart' as http;

class UserIdScreen extends StatefulWidget {
  @override
  _UserIdScreenState createState() => _UserIdScreenState();
}

class _UserIdScreenState extends State<UserIdScreen> {
  final TextEditingController keyController = TextEditingController();
  bool isLoading = false;
  String? userId;
  String? errorMessage;

  @override
  void dispose() {
    keyController.dispose();
    super.dispose();
  }

  Future<void> fetchUserId(String key) async {
    setState(() {
      isLoading = true;
      userId = null;
      errorMessage = null;
    });

    final url = Uri.parse(globals.host + '/receptionist/getUserId');

    try {
      final response = await http.post(
        url,
        headers: {
          'authorization': globals.token,
          'Content-Type': 'application/json'
        },
        body: jsonEncode({'key': key}),
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse.isNotEmpty) {
          final Map<String, dynamic> data = jsonResponse[0];
          setState(() {
            userId = data['id'].toString(); // Convert 'id' to String
            globals.userId =data['id'].toString();
            isLoading = false;
          });
        } else {
          throw Exception('Empty response received.');
        }
      } else {
        throw Exception(
            'Failed to fetch user ID. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching user ID: $e');
      setState(() {
        errorMessage = 'Error fetching user ID';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fetch User ID'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: keyController,
              decoration: InputDecoration(
                hintText: 'Enter key',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                String key = keyController.text.trim();
                if (key.isNotEmpty) {
                  fetchUserId(key);
                } else {
                  setState(() {
                    errorMessage = 'Please enter a key';
                  });
                }
              },
              child: Text('Fetch User ID'),
            ),
            SizedBox(height: 16.0),
            if (isLoading)
              CircularProgressIndicator()
            else if (errorMessage != null)
              Text(errorMessage!, style: TextStyle(color: Colors.red))
            else if (userId != null)
              Text('User ID: $userId', style: TextStyle(fontSize: 24.0)),
          ],
        ),
      ),
    );
  }
}
