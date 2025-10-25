import 'dart:convert';
import 'package:flutter/material.dart';

import '../../globals.dart' as globals;
import 'package:http/http.dart' as http;

import '../../const/colors.dart';

class StoreLog {
  final String title;
  final int count;
  final DateTime createDate;
  final int state;

  StoreLog({
    required this.title,
    required this.count,
    required this.createDate,
    required this.state,
  });

  factory StoreLog.fromJson(Map<String, dynamic> json) {
    return StoreLog(
      title: json['title'] ?? '',
      count: json['count'] ?? 0,
      createDate: DateTime.parse(json['createDate'] ?? '1970-01-01T00:00:00Z'),
      state: json['state'] ?? 0,
    );
  }
}

class StoreLogsResponse {
  final int pages;
  final List<StoreLog> result;

  StoreLogsResponse({
    required this.pages,
    required this.result,
  });

  factory StoreLogsResponse.fromJson(Map<String, dynamic> json) {
    return StoreLogsResponse(
      pages: json['pages'] ?? 1,
      result:
          (json['result'] as List).map((e) => StoreLog.fromJson(e)).toList(),
    );
  }
}

class StoreLogsScreen extends StatefulWidget {
  @override
  _StoreLogsScreenState createState() => _StoreLogsScreenState();
}

class _StoreLogsScreenState extends State<StoreLogsScreen> {
  final String baseUrl = globals.host + '/store/storeLog';
  List<StoreLog> _storeLogs = [];
  int _currentPage = 1; // Initial page number
  bool _isLoading = false;
  int _totalPages = 1; // Total pages from server response

  @override
  void initState() {
    super.initState();
    _fetchStoreLogs(_currentPage);
  }

  Future<void> _fetchStoreLogs(int page) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        body: jsonEncode({
          'start': page.toString(),
          'count': '20', // Fetch 20 items per page
        }),
        headers: {
          'authorization': globals.token,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        StoreLogsResponse storeLogsResponse =
            StoreLogsResponse.fromJson(jsonDecode(response.body));
        setState(() {
          _storeLogs = storeLogsResponse.result;
          _totalPages = storeLogsResponse.pages;
          _currentPage = page;
        });
      } else {
        throw Exception('Failed to load store logs');
      }
    } catch (e) {
      print('Error fetching store logs: $e');
      // Handle error
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onPageChanged(int page) {
    if (page <= _totalPages && page != _currentPage) {
      _fetchStoreLogs(page);
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
      backgroundColor: AppColors.greenLight,
      appBar: AppBar(
        backgroundColor: AppColors.greenLight,
        title: Text('Store Logs'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _storeLogs.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text('Title: ${_storeLogs[index].title}'),
                        subtitle: Text(
                            'Count: ${_storeLogs[index].count}\nState: ${_storeLogs[index].state == 1 ? 'Enter' : 'to delivery'}\nCreate Date: ${_storeLogs[index].createDate}'),
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
