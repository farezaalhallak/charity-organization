import 'dart:convert';
import 'package:flutter/material.dart';
import '../../globals.dart' as globals;
import 'package:http/http.dart' as http;

import 'donationRequest.dart';

class PreviousDonationRequest {
  final int id;
  final String title;
  final int status;

  PreviousDonationRequest({
    required this.id,
    required this.title,
    required this.status,
  });

  factory PreviousDonationRequest.fromJson(Map<String, dynamic> json) {
    return PreviousDonationRequest(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      status: json['status'] ?? 0,
    );
  }
}

class PreviousDonationRequestsScreen extends StatefulWidget {
  @override
  _PreviousDonationRequestsScreenState createState() =>
      _PreviousDonationRequestsScreenState();
}

class _PreviousDonationRequestsScreenState
    extends State<PreviousDonationRequestsScreen> {



  Future<void> _navigateToDetails(int id,BuildContext context,int userId) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>DonationRequestsScreenn(id: id,userId: userId,),
      ),
    );
  }






  final String baseUrl = globals.host + '/receptionist/previousDonationRequest';
  List<PreviousDonationRequest> _previousDonationRequests = [];
  bool _isLoading = false;
  TextEditingController _idController = TextEditingController(text: globals.userId);

  Future<void> _fetchPreviousDonationRequests(int idUser) async {
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
        List<PreviousDonationRequest> previousDonationRequests = jsonResponse
            .map((e) => PreviousDonationRequest.fromJson(e))
            .toList();
        setState(() {
          _previousDonationRequests = previousDonationRequests;
        });
      } else {
        throw Exception('Failed to load previous donation requests');
      }
    } catch (e) {
      print('Error fetching previous donation requests: $e');
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
        title: Text('Previous Donation Requests'),
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
                  _fetchPreviousDonationRequests(idUser);
                } else {
                  // Handle invalid ID input
                  print('Please enter a valid ID');
                }
              },
              child: Text('Fetch Previous Donation Requests'),
            ),
            SizedBox(height: 20),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : _previousDonationRequests.isEmpty
                ? Center(child: Text('No previous donation requests found'))
                : Expanded(
              child: ListView.builder(
                itemCount: _previousDonationRequests.length,
                itemBuilder: (context, index) {
                  final request = _previousDonationRequests[index];
                  return Card(
                    elevation: 4, // Adjust the shadow elevation here
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      onTap: () {

                        _navigateToDetails( request.id,context,int.parse(_idController.text) as int);
                        print("_navigateToDetails " );

                      },
                      contentPadding: EdgeInsets.all(16),
                      title: Text('ID: ${request.id}'),
                      subtitle: Text('Title: ${request.title}'),
                      trailing: Text('Status: ${request.status}'),
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
