import 'dart:convert';
import 'package:flutter/material.dart';

import '../../globals.dart' as globals;
import 'package:http/http.dart' as http;

class PreviousRequest {
  final int id;
  final String description1;
  final int status;

  PreviousRequest({
    required this.id,
    required this.description1,
    required this.status,
  });

  factory PreviousRequest.fromJson(Map<String, dynamic> json) {
    return PreviousRequest(
      id: json['id'] ?? 0,
      description1: json['description1'] ?? '',
      status: json['status'] ?? 0,
    );
  }
}

class PreviousRequestsScreen extends StatefulWidget {
  @override
  _PreviousRequestsScreenState createState() =>
      _PreviousRequestsScreenState();
}

class _PreviousRequestsScreenState extends State<PreviousRequestsScreen> {
  final String baseUrl = globals.host + '/receptionist/previousRequest';
  List<PreviousRequest> _previousRequests = [];
  bool _isLoading = false;
  TextEditingController _idController = TextEditingController(text: globals.userId);

  Future<void> _fetchPreviousRequests(int idUser) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'authorization': globals.token,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'idUser': idUser,
        }),
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = jsonDecode(response.body);
        List<PreviousRequest> previousRequests =
        jsonResponse.map((e) => PreviousRequest.fromJson(e)).toList();
        setState(() {
          _previousRequests = previousRequests;
        });
      } else {
        throw Exception('Failed to load previous requests');
      }
    } catch (e) {
      print('Error fetching previous requests: $e');
      // Handle error
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _cancelRequest(int idRequest, int idUser) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://localhost:8000/receptionist/cancellingRequest'),
        headers: {
          'authorization': globals.token,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'idRequest': idRequest,
          'idUser': idUser,
        }),
      );

      // Print the status code and response body
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        // Show success dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Success'),
              content: Text('Request cancelled successfully'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );

        // Optionally, refresh the list after cancellation
        _fetchPreviousRequests(idUser);
      } else {
        throw Exception('Failed to cancel request');
      }
    } catch (e) {
      print('Error cancelling request: $e');
      // Handle error
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Previous Requests'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _idController,
              decoration: InputDecoration(
                labelText: 'Enter User ID',
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final idUser = int.tryParse(_idController.text);
                if (idUser != null) {
                  _fetchPreviousRequests(idUser);
                } else {
                  // Handle invalid ID input
                  print('Please enter a valid ID');
                }
              },
              child: Text('Fetch Previous Requests'),
            ),
            SizedBox(height: 20),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : _previousRequests.isEmpty
                ? Center(child: Text('No previous requests found'))
                : Expanded(
              child: ListView.builder(
                itemCount: _previousRequests.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 4.0, // Add shadow effect
                    margin: EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16), // Margin around each card
                    child: ListTile(
                      contentPadding: EdgeInsets.all(
                          16.0), // Padding inside the card
                      title: Text('ID: ${_previousRequests[index].id}'),
                      subtitle: Text(
                          'Description: ${_previousRequests[index].description1}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                              'Status: ${_previousRequests[index].status}'),
                          SizedBox(width: 10),
                          IconButton(
                            icon: Icon(Icons.cancel),
                            onPressed: () {
                              _cancelRequest(
                                  _previousRequests[index].id,
                                  int.parse(_idController.text));
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
