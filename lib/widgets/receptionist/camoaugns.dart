import 'dart:convert';
import 'package:flutter/material.dart';

import '../../globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'package:untitled/const/colors.dart';
import 'camoaugnsdetials.dart'; // Import the details screen

class Campaign {
  final int id;
  final String title;
  final String imageUrl;

  Campaign({
    required this.id,
    required this.title,
    required this.imageUrl,
  });

  factory Campaign.fromJson(Map<String, dynamic> json) {
    return Campaign(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      // بناء URL كامل للصور إذا كان المسار نسبي
      imageUrl: globals.host + '/' + (json['imageUrl'] ?? '').replaceAll('\\', '/'),
    );
  }
}

class CampaignsResponse {
  final int pages;
  final List<Campaign> result;

  CampaignsResponse({
    required this.pages,
    required this.result,
  });

  factory CampaignsResponse.fromJson(Map<String, dynamic> json) {
    return CampaignsResponse(
      pages: json['pages'] ?? 1,
      result:
      (json['result'] as List).map((e) => Campaign.fromJson(e)).toList(),
    );
  }
}

class CampaignsScreen extends StatefulWidget {
  @override
  _CampaignsScreenState createState() => _CampaignsScreenState();
}

class _CampaignsScreenState extends State<CampaignsScreen> {
  final String baseUrl = globals.host + '/receptionist/campaigns';
  List<Campaign> _campaigns = [];
  int _currentPage = 1; // Initial page number
  bool _isLoading = false;
  int _totalPages = 1; // Total pages from server response

  @override
  void initState() {
    super.initState();
    _fetchCampaigns(_currentPage);
  }

  Future<void> _fetchCampaigns(int page) async {
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
        CampaignsResponse campaignsResponse =
        CampaignsResponse.fromJson(jsonDecode(response.body));
        setState(() {
          _campaigns = campaignsResponse.result;
          _totalPages = campaignsResponse.pages;
          _currentPage = page;
        });
      } else {
        throw Exception('Failed to load campaigns');
      }
    } catch (e) {
      print('Error fetching campaigns: $e');
      // Handle error
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onPageChanged(int page) {
    if (page <= _totalPages && page != _currentPage) {
      _fetchCampaigns(page);
    }
  }

  Future<void> _navigateToDetails(int id) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CampaignDetailScreen(campaignId: id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Campaigns'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // عدد العناصر في كل صف
                crossAxisSpacing: 20.0,
                mainAxisSpacing: 8.0,
                childAspectRatio:
                2 / 3, // التحكم في نسبة عرض وارتفاع الكارد
              ),
              padding: EdgeInsets.all(8.0),
              itemCount: _campaigns.length,
              itemBuilder: (context, index) {
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: InkWell(
                    onTap: () => _navigateToDetails(_campaigns[index].id),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 180, // تحديد ارتفاع الصورة
                          child: ClipRRect(
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(15)),
                            child: Image.network(
                              _campaigns[index].imageUrl,
                              fit: BoxFit.cover, // ضبط الصورة لتغطية المساحة المحددة
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.broken_image,
                                  size: 50,
                                  color: Colors.grey,
                                );
                              },
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(15),
                          child: Text(
                            _campaigns[index].title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
