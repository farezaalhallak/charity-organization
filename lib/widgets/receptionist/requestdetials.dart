import 'dart:convert';
import 'package:flutter/material.dart';

import '../../globals.dart' as globals;
import 'package:http/http.dart' as http;

class RequestDetails {
  final String description2;
  final int priority;

  RequestDetails({
    required this.description2,
    required this.priority,
  });

  factory RequestDetails.fromJson(Map<String, dynamic> json) {
    return RequestDetails(
      description2: json['description2'] ?? '',
      priority: json['priority'] ?? 0,
    );
  }
}

class RequestDetailsScreen extends StatefulWidget {
  final int id;

  RequestDetailsScreen({required this.id});

  @override
  _RequestDetailsScreenState createState() => _RequestDetailsScreenState();
}

class _RequestDetailsScreenState extends State<RequestDetailsScreen> {
  final String baseUrl = globals.host + '/receptionist';
  late RequestDetails _requestDetails;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRequestDetails(widget.id);
  }

  Future<void> _fetchRequestDetails(int id) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/requestDetails'),
        body: jsonEncode({'id': id}),
        headers: {
          'authorization': globals.token,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _requestDetails = RequestDetails.fromJson(data[0]);
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load request details');
      }
    } catch (e) {
      print('Error fetching request details: $e');
      // Handle error
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Request Details'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Description: ${_requestDetails.description2}'),
                  SizedBox(height: 8),
                  Text('Priority: ${_requestDetails.priority}'),
                ],
              ),
            ),
    );
  }
}
