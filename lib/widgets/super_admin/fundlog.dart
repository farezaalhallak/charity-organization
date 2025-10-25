import 'dart:convert';
import 'package:flutter/material.dart';

import '../../globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'package:untitled/const/colors.dart';

// Model class for FundLog
class FundLog {
  final int id;
  int count;
  final DateTime createDate;
  final int state;
  final String userKeyId;

  FundLog({
    required this.id,
    required this.count,
    required this.createDate,
    required this.state,
    required this.userKeyId,
  });

  factory FundLog.fromJson(Map<String, dynamic> json) {
    return FundLog(
      id: json['id'] ?? 0,
      count: json['count'] ?? 0,
      createDate: DateTime.parse(json['createDate'] ?? '1970-01-01T00:00:00Z'),
      state: json['state'] ?? 0,
      userKeyId: (json['useridkey'] as String)
          .trim(), // Use trim() to remove whitespace
    );
  }
}

// Model class for the response containing a list of FundLog
class FundLogsResponse {
  final int pages;
  final List<FundLog> result;

  FundLogsResponse({
    required this.pages,
    required this.result,
  });

  factory FundLogsResponse.fromJson(Map<String, dynamic> json) {
    return FundLogsResponse(
      pages: json['pages'] ?? 1,
      result: (json['result'] as List).map((e) => FundLog.fromJson(e)).toList(),
    );
  }
}

// Main screen displaying fund logs
class FundLogsScreen extends StatefulWidget {
  @override
  _FundLogsScreenState createState() => _FundLogsScreenState();
}

class _FundLogsScreenState extends State<FundLogsScreen> {
  final String baseUrl = globals.host + '/superAdmin/fundLog';
  List<FundLog> _fundLogs = [];
  int _currentPage = 1; // Initial page number
  bool _isLoading = false;
  int _totalPages = 1; // Total pages from server response

  @override
  void initState() {
    super.initState();
    _fetchFundLogs(_currentPage);
  }

  Future<void> _fetchFundLogs(int page) async {
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
        FundLogsResponse fundLogsResponse =
            FundLogsResponse.fromJson(jsonDecode(response.body));
        setState(() {
          _fundLogs = fundLogsResponse.result;
          _totalPages = fundLogsResponse.pages;
          _currentPage = page;
        });
      } else {
        throw Exception('Failed to load fund logs');
      }
    } catch (e) {
      print('Error fetching fund logs: $e');
      // Handle error
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onPageChanged(int page) {
    if (page <= _totalPages && page != _currentPage) {
      _fetchFundLogs(page);
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
              color:
                  _currentPage == index + 1 ? AppColors.greenDark : Colors.grey,
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
        title: Text('Fund Logs'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _fundLogs.length,
                    itemBuilder: (context, index) {
                      final fundLog = _fundLogs[index];
                      return Card(
                        elevation:
                            4, // Adjust the elevation to change shadow intensity
                        margin: EdgeInsets.all(
                            8), // Add some margin around the card
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(8), // Rounded corners
                        ),
                        child: ListTile(
                          contentPadding:
                              EdgeInsets.all(16), // Padding inside the card
                          title: Text('ID: ${fundLog.id}',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                              'Count: ${fundLog.count}\nState: ${fundLog.state == 1 ? 'Enter' : 'to delivery'}\nUser Key ID: ${fundLog.userKeyId}'),
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
