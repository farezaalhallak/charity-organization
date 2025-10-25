import 'dart:convert';
import 'package:flutter/material.dart';

import '../../globals.dart' as globals;
import 'package:http/http.dart' as http;

class DeleteCampaignScreen extends StatefulWidget {
  final int campaignId;

  DeleteCampaignScreen({required this.campaignId});

  @override
  _DeleteCampaignScreenState createState() => _DeleteCampaignScreenState();
}

class _DeleteCampaignScreenState extends State<DeleteCampaignScreen> {
  bool _isDeleting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _deleteCampaign(); // Start the deletion process when the screen is loaded
  }

  Future<void> _deleteCampaign() async {
    setState(() {
      _isDeleting = true;
      _errorMessage = null;
    });

    try {
      final url =
          Uri.parse(globals.host + '/mediaTeam/DeletePreviousCampaigns');
      final response = await http.post(
        url,
        headers: {
          'authorization': globals.token,
          'Content-Type': 'application/json'
        },
        body: jsonEncode({'id': widget.campaignId}),
      );

      if (response.statusCode == 200) {
        String responseBody = response.body.trim();
        print('Response from server: $responseBody'); // Log response body

        if (responseBody == "Done") {
          Navigator.pop(context, true); // Return true to indicate success
        } else {
          setState(() {
            _errorMessage = 'Unexpected response format';
          });
        }
      } else {
        print(
            'Error: Server responded with status code ${response.statusCode}');
        setState(() {
          _errorMessage =
              'Failed to delete. Server responded with status code ${response.statusCode}';
        });
      }
    } catch (e) {
      print('Error: $e'); // Log error
      setState(() {
        _errorMessage = 'Failed to delete: $e';
      });
    } finally {
      setState(() {
        _isDeleting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Deleting Campaign'),
      ),
      body: Center(
        child: _isDeleting
            ? CircularProgressIndicator()
            : _errorMessage != null
                ? Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red),
                  )
                : Text('Campaign deleted successfully!'),
      ),
    );
  }
}
