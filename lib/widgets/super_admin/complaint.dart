import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:untitled/const/colors.dart';

import '../../globals.dart' as globals;
import 'package:http/http.dart' as http;

class Complaint {
  final int id;
  final int userId;
  final String complaint;
  final DateTime createDate;

  Complaint({
    required this.id,
    required this.userId,
    required this.complaint,
    required this.createDate,
  });

  factory Complaint.fromJson(Map<String, dynamic> json) {
    return Complaint(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      complaint: json['complaint'] ?? '',
      createDate: DateTime.parse(json['createDate'] ?? '1970-01-01T00:00:00Z'),
    );
  }
}

class ComplaintsResponse {
  final int pages;
  final List<Complaint> result;

  ComplaintsResponse({
    required this.pages,
    required this.result,
  });

  factory ComplaintsResponse.fromJson(Map<String, dynamic> json) {
    return ComplaintsResponse(
      pages: json['pages'] ?? 1,
      result:
          (json['result'] as List).map((e) => Complaint.fromJson(e)).toList(),
    );
  }
}

class ShowComplaintScreen extends StatefulWidget {
  @override
  _ShowComplaintScreenState createState() => _ShowComplaintScreenState();
}

class _ShowComplaintScreenState extends State<ShowComplaintScreen> {
  final String baseUrl = globals.host + '/superAdmin/showComplaint';
  List<Complaint> _complaints = [];
  int _currentPage = 1; // Initial page number
  bool _isLoading = false;
  int _totalPages = 1; // Total pages from server response

  @override
  void initState() {
    super.initState();
    _fetchComplaints(_currentPage);
  }

  Future<void> _fetchComplaints(int page) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        body: jsonEncode({
          'start': page.toString(),
          'count': '10', // Fetch 10 items per page
        }),
        headers: {
          'authorization': globals.token,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        ComplaintsResponse complaintsResponse =
            ComplaintsResponse.fromJson(jsonDecode(response.body));
        setState(() {
          _complaints = complaintsResponse.result;
          _totalPages = complaintsResponse.pages;
          _currentPage = page;
        });

        // Print the fetched complaints to console
        _complaints.forEach((complaint) {
          print('ID: ${complaint.id}');
          print('User ID: ${complaint.userId}');
          print('Complaint: ${complaint.complaint}');
          print('Date: ${complaint.createDate}');
          print('----------------------');
        });
      } else {
        throw Exception('Failed to load complaints');
      }
    } catch (e) {
      print('Error fetching complaints: $e');
      // Handle error
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onPageChanged(int page) {
    if (page <= _totalPages && page != _currentPage) {
      _fetchComplaints(page);
    }
  }

  Widget _buildPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_totalPages, (index) {
        return InkWell(
          onTap: () => _onPageChanged(index + 1),
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 4),
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _currentPage == index + 1 ? AppColors.greenDark : Colors.grey,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${index + 1}',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Complaints'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _complaints.length,
                    itemBuilder: (context, index) {
                      final complaint = _complaints[index];
                      return Card(
                        margin:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                        elevation: 5,
                        child: Padding(
                          padding: EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ID: ${complaint.id}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8),
                              Text('User ID: ${complaint.userId}'),
                              SizedBox(height: 8),
                              Text('Complaint: ${complaint.complaint}'),
                              SizedBox(height: 8),
                              Text(
                                  'Date: ${complaint.createDate.toLocal()}'), // Format date as needed
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                _buildPagination(),
              ],
            ),
    );
  }
}
