import 'dart:convert';
import 'package:flutter/material.dart';
import '../../globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'package:untitled/const/colors.dart';
import 'package:untitled/widgets/receptionist/requestdetials.dart';

class RequestLog {
  final int id;
  String title;
  final String work;
  final String reason;
  final String idUser;

  RequestLog({
    required this.id,
    required this.title,
    required this.work,
    required this.reason,
    required this.idUser,
  });

  factory RequestLog.fromJson(Map<String, dynamic> json) {
    return RequestLog(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      work: json['work'] ?? '',
      reason: json['reason'] ?? '',
      idUser: json['idUser'] ?? '',
    );
  }
}

class RequestsResponse {
  final int pages;
  final List<RequestLog> result;

  RequestsResponse({
    required this.pages,
    required this.result,
  });

  factory RequestsResponse.fromJson(Map<String, dynamic> json) {
    return RequestsResponse(
      pages: json['pages'] ?? 1,
      result:
      (json['result'] as List).map((e) => RequestLog.fromJson(e)).toList(),
    );
  }
}

class RequestsScreen extends StatefulWidget {
  @override
  _RequestsScreenState createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  final String baseUrl = globals.host + '/receptionist';
  List<RequestLog> _requestLogs = [];
  int _currentPage = 1; // Initial page number
  bool _isLoading = false;
  int _totalPages = 1; // Total pages from server response

  // Variables for adding new request
  late String _newTitle;
  late String _newWork;
  late String _newReason;
  late String _newUserId;

  @override
  void initState() {
    super.initState();
    _fetchRequestLogs(_currentPage);
  }

  Future<void> _fetchRequestLogs(int page) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/requests'),
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
        RequestsResponse requestsResponse =
        RequestsResponse.fromJson(jsonDecode(response.body));
        setState(() {
          _requestLogs = requestsResponse.result;
          _totalPages = requestsResponse.pages;
          _currentPage = page;
        });
      } else {
        throw Exception('Failed to load request logs');
      }
    } catch (e) {
      print('Error fetching request logs: $e');
      // Handle error
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addRequest(
      String title, String work, String reason, String idUser) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/addRequest'),
        body: jsonEncode({
          'title': title,
          'work': work,
          'reason': reason,
          'idUser': idUser,
        }),
        headers: {
          'authorization': globals.token,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print('Request added successfully');
        // Refresh the list after adding
        _fetchRequestLogs(_currentPage);
      } else {
        throw Exception('Failed to add request');
      }
    } catch (e) {
      print('Error adding request: $e');
      // Handle error
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onPageChanged(int page) {
    _fetchRequestLogs(page);
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
        title: Text('Request Logs'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            // Request Logs List
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _requestLogs.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 4.0, // Add shadow effect
                  margin: EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16), // Margin around each card
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16.0),
                    title: Text('ID: ${_requestLogs[index].id}'),
                    subtitle: Text('Title: ${_requestLogs[index].title}'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RequestDetailsScreen(
                              id: _requestLogs[index].id),
                        ),
                      );
                    },
                  ),
                );
              },
            ),

            // Add New Request Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Add New Request'),
                  TextField(
                    decoration: InputDecoration(labelText: 'Title'),
                    onChanged: (value) => _newTitle = value,
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: 'Work'),
                    onChanged: (value) => _newWork = value,
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: 'Reason'),
                    onChanged: (value) => _newReason = value,
                  ),
                  TextField(

                    decoration: InputDecoration(labelText: 'ID User'),
                    onChanged: (value) => _newUserId = value,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      _addRequest(
                          _newTitle, _newWork, _newReason, _newUserId);
                    },
                    child: Text('Add Request'),
                  ),
                ],
              ),
            ),

            // Pagination
            _buildPagination(),
          ],
        ),
      ),
    );
  }
}
