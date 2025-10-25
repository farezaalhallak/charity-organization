import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:untitled/const/colors.dart';

import '../../globals.dart' as globals;
import 'package:http/http.dart' as http;

class CampaignDonationLog {
  final String userKeyId;
  final int count;
  final DateTime createDate;
  final String requestTitle;

  CampaignDonationLog({
    required this.userKeyId,
    required this.count,
    required this.createDate,
    required this.requestTitle,
  });

  factory CampaignDonationLog.fromJson(Map<String, dynamic> json) {
    return CampaignDonationLog(
      userKeyId: (json['useridkey'] as String).trim(),
      count: json['count'] ?? 0,
      createDate: DateTime.parse(json['createDate'] ?? '1970-01-01T00:00:00Z'),
      requestTitle: json['requesttitle'] ?? '',
    );
  }
}

class CampaignDonationLogsResponse {
  final int pages;
  final List<CampaignDonationLog> result;

  CampaignDonationLogsResponse({
    required this.pages,
    required this.result,
  });

  factory CampaignDonationLogsResponse.fromJson(Map<String, dynamic> json) {
    return CampaignDonationLogsResponse(
      pages: json['pages'] ?? 1,
      result: (json['result'] as List)
          .map((e) => CampaignDonationLog.fromJson(e))
          .toList(),
    );
  }
}

class CampaignDonationLogsScreen extends StatefulWidget {
  @override
  _CampaignDonationLogsScreenState createState() =>
      _CampaignDonationLogsScreenState();
}

class _CampaignDonationLogsScreenState
    extends State<CampaignDonationLogsScreen> {
  final String baseUrl = globals.host + '/superAdmin/campaignDonationLog';
  List<CampaignDonationLog> _logs = [];
  int _currentPage = 1;
  bool _isLoading = false;
  int _totalPages = 1;

  @override
  void initState() {
    super.initState();
    _fetchLogs(_currentPage);
  }

  Future<void> _fetchLogs(int page) async {
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
        CampaignDonationLogsResponse logsResponse =
            CampaignDonationLogsResponse.fromJson(jsonDecode(response.body));
        setState(() {
          _logs = logsResponse.result;
          _totalPages = logsResponse.pages;
          _currentPage = page;
        });

        // Print the fetched logs to console
        _logs.forEach((log) {
          print('User Key ID: ${log.userKeyId}');
          print('Count: ${log.count}');
          print('Request Title: ${log.requestTitle}');
          print('----------------------');
        });
      } else {
        throw Exception('Failed to load campaign donation logs');
      }
    } catch (e) {
      print('Error fetching campaign donation logs: $e');
      // Handle error
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onPageChanged(int page) {
    if (page <= _totalPages && page != _currentPage) {
      _fetchLogs(page);
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
        title: Text('Campaign Donation Logs'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _logs.length,
                    itemBuilder: (context, index) {
                      final log = _logs[index];
                      return Card(
                        margin:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                        elevation: 5,
                        child: ListTile(
                          contentPadding: EdgeInsets.all(15),
                          title: Text('User Key ID: ${log.userKeyId}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
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
