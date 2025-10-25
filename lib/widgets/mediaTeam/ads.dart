import 'dart:convert';
import 'package:flutter/material.dart';

import '../../globals.dart' as globals;
import 'package:http/http.dart' as http;

import '../../const/colors.dart';
import 'addAds.dart';

// Ad Model
class Ad {
  final int id;
  final String title;
  final String? description;
  final String imageUrl;
  final bool isDisable;
  final DateTime createDate;

  Ad({
    required this.id,
    required this.title,
    this.description,
    required this.imageUrl,
    required this.isDisable,
    required this.createDate,
  });

  factory Ad.fromJson(Map<String, dynamic> json) {
    return Ad(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'],
      imageUrl: json['imageUrl'] ?? '',
      isDisable: json['isDisable'] ?? false,
      createDate: DateTime.parse(json['createDate'] ?? '1970-01-01T00:00:00Z'),
    );
  }
}

// Ads Response Model
class AdsResponse {
  final int pages;
  final List<Ad> result;

  AdsResponse({
    required this.pages,
    required this.result,
  });

  factory AdsResponse.fromJson(Map<String, dynamic> json) {
    return AdsResponse(
      pages: json['pages'] ?? 1,
      result: (json['result'] as List).map((e) => Ad.fromJson(e)).toList(),
    );
  }
}

// Ads Screen
class AdsScreen extends StatefulWidget {
  @override
  _AdsScreenState createState() => _AdsScreenState();
}

class _AdsScreenState extends State<AdsScreen> {
  final String baseUrl = globals.host + '/mediaTeam/ads';
  final String deleteUrl = globals.host + '/mediaTeam/deleteAds';
  List<Ad> _ads = [];
  int _currentPage = 1;
  bool _isLoading = false;
  int _totalPages = 1;

  @override
  void initState() {
    super.initState();
    _fetchAds(_currentPage);
  }

  Future<void> _fetchAds(int page) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        body: jsonEncode({
          'start': page.toString(),
          'count': '2', // Fetch 2 items per page
        }),
        headers: {
          'authorization': globals.token,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        AdsResponse adsResponse =
            AdsResponse.fromJson(jsonDecode(response.body));
        setState(() {
          _ads = adsResponse.result;
          _totalPages = adsResponse.pages;
          _currentPage = page;
        });
      } else {
        print('Failed to load ads. Status code: ${response.statusCode}');
        throw Exception('Failed to load ads');
      }
    } catch (e) {
      print('Error fetching ads: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onPageChanged(int page) {
    if (page <= _totalPages && page != _currentPage) {
      _fetchAds(page);
    }
  }

  Future<void> _deleteAd(int id) async {
    try {
      final response = await http.post( Uri.parse(deleteUrl),
        body: jsonEncode({'id': id.toString()}),
        headers: {
          'authorization': globals.token,
          'Content-Type': 'application/json'
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ad deleted successfully')),
        );
        _fetchAds(_currentPage); // Refresh the ads list after deletion
      } else {
        print('Failed to delete ad. Status code: ${response.statusCode}');
        throw Exception('Failed to delete ad');
      }
    } catch (e) {
      print('Error deleting ad: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting ad')),
      );
    }
  }

  void _navigateToAddAdScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddAdScreen()),
    );

    if (result == true) {
      _fetchAds(_currentPage); // Refresh the ads list after adding a new ad
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(

        title: Text('Ads'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _navigateToAddAdScreen,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: GridView.builder(
                    padding: EdgeInsets.all(8.0),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // Number of columns in the grid
                      crossAxisSpacing: 9.0, // Spacing between columns
                      mainAxisSpacing: 9.0, // Spacing between rows
                      childAspectRatio: 3/2, // Aspect ratio of each card
                    ),
                    itemCount: _ads.length,
                    itemBuilder: (context, index) {
                      final ad = _ads[index];
                      return Card(
                        elevation: 7.0, // Add shadow effect
                        margin: EdgeInsets.all(8),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Control image size
                              SizedBox(
                                width: double.infinity,
                                height: 100, // Specify the height
                                child: Image.network(
                                  globals.host + '/${ad.imageUrl}',
                                  fit: BoxFit.cover,
                                ),
                              ),
                              SizedBox(height: 8),
                              // Ad details with delete button in one row
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Column for title and description
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          ad.title,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          ad.description ?? "No description",
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    color: Colors.red,
                                    onPressed: () => _deleteAd(ad.id),
                                  ),
                                ],
                              ),
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
}
