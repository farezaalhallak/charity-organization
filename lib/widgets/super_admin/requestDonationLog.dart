import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:untitled/const/colors.dart';

import '../../globals.dart' as globals;
import 'package:http/http.dart' as http;

class RequestDonationLog {
  final int useridkey;
  final int count;
  final DateTime createDate;
  final String requestTitle;

  RequestDonationLog({
    required this.useridkey,
    required this.count,
    required this.createDate,
    required this.requestTitle,
  });

  factory RequestDonationLog.fromJson(Map<String, dynamic> json) {
    return RequestDonationLog(
      useridkey: json['useridkey'] ?? 0,
      count: json['count'] ?? 0,
      createDate: DateTime.parse(json['createDate'] ?? '1970-01-01T00:00:00Z'),
      requestTitle: json['requesttitle'] ?? '',
    );
  }
}

class RequestDonationLogsResponse {
  final int pages;
  final List<RequestDonationLog> result;

  RequestDonationLogsResponse({
    required this.pages,
    required this.result,
  });

  factory RequestDonationLogsResponse.fromJson(Map<String, dynamic> json) {
    return RequestDonationLogsResponse(
      pages: json['pages'] ?? 1,
      result: (json['result'] as List)
          .map((e) => RequestDonationLog.fromJson(e))
          .toList(),
    );
  }
}

class RequestDonationLogsScreen extends StatefulWidget {
  @override
  _RequestDonationLogsScreenState createState() =>
      _RequestDonationLogsScreenState();
}

class _RequestDonationLogsScreenState extends State<RequestDonationLogsScreen> {
  final String baseUrl = globals.host + '/superAdmin/requestDonationLog';
  List<RequestDonationLog> _requestDonationLogs = [];
  int _currentPage = 1; // Initial page number
  bool _isLoading = false;
  int _totalPages = 1; // Total pages from server response

  @override
  void initState() {
    super.initState();
    _fetchRequestDonationLogs(_currentPage);
  }

  Future<void> _fetchRequestDonationLogs(int page) async {
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
        RequestDonationLogsResponse requestLogsResponse =
            RequestDonationLogsResponse.fromJson(jsonDecode(response.body));
        setState(() {
          _requestDonationLogs = requestLogsResponse.result;
          _totalPages = requestLogsResponse.pages;
          _currentPage = page;
        });

        // Print the fetched logs to console
        _requestDonationLogs.forEach((log) {
          print('User ID Key: ${log.useridkey}');
          print('Count: ${log.count}');
          print('Date: ${log.createDate}');
          print('Request Title: ${log.requestTitle}');
          print('----------------------');
        });
      } else {
        throw Exception('Failed to load request donation logs');
      }
    } catch (e) {
      print('Error fetching request donation logs: $e');
      // Handle error
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onPageChanged(int page) {
    if (page <= _totalPages && page != _currentPage) {
      _fetchRequestDonationLogs(page);
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
        title: Text('Request Donation Logs'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _requestDonationLogs.length,
                    itemBuilder: (context, index) {
                      final log = _requestDonationLogs[index];
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
                                'User ID Key: ${log.useridkey}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8),
                              Text('Count: ${log.count}'),
                              SizedBox(height: 8),
                              Text('Request Title: ${log.requestTitle}'),
                              SizedBox(height: 8),
                              Text(
                                  'Date: ${log.createDate.toLocal()}'), // Format date as needed
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
