import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:untitled/const/colors.dart';

import '../../globals.dart' as globals;
import 'package:http/http.dart' as http;

class ComplaintScreen extends StatefulWidget {
  @override
  _ComplaintScreenState createState() => _ComplaintScreenState();
}

class _ComplaintScreenState extends State<ComplaintScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _userIdController = TextEditingController(text: globals.userId);
  Future<void> _sendComplaint() async {
    setState(() {
      // No need to reset submission status as we're using a dialog
    });

    try {
      final url = Uri.parse(globals.host + '/receptionist/addComplaint');
      final requestBody = {
        'descr': _descriptionController.text,
        'idUser': _userIdController.text,
      };
      print('Request body: $requestBody');

      final response = await http.post(
        url,
        body: jsonEncode(requestBody),
        headers: {
          'authorization': globals.token,
          'Content-Type': 'application/json'
        },
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        // Successful submission
        print('Complaint submitted successfully');
        // Show success dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Success'),
            content: Text('Complaint submitted successfully!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
        );
      } else {
        // Handle error response
        print('Failed to submit complaint: ${response.statusCode}');
        // Show error dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content:
                Text('Failed to submit complaint. Please try again later.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('Error submitting complaint: $e');
      // Handle network or other errors
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('An error occurred. Please try again later.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Submit Complaint'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                filled: true,
                fillColor:  AppColors.light, // Set the background color here
                border: InputBorder.none, // Remove the border
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _userIdController,
              decoration: InputDecoration(
                labelText: 'User ID',
                filled: true,
                fillColor: AppColors.light, // Set the background color here
                border: InputBorder.none, // Remove the border
              ),
            ),
            SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: _sendComplaint,
              child: Text('Submit Complaint'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _userIdController.dispose();
    super.dispose();
  }
}
