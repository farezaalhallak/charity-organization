import 'dart:convert';
import 'package:flutter/material.dart';

import '../../globals.dart' as globals;
import 'package:http/http.dart' as http;

import '../../const/colors.dart';
import 'AddCampaignScreen.dart';
import 'deletecompain.dart';
import 'detialscamgous.dart';

class PreviousCampaignsScreen extends StatefulWidget {
  @override
  _PreviousCampaignsScreenState createState() =>
      _PreviousCampaignsScreenState();
}

class _PreviousCampaignsScreenState extends State<PreviousCampaignsScreen> {
  List<Map<String, dynamic>> previousCampaigns = [];
  int currentPage = 1;
  int totalPages = 1;

  @override
  void initState() {
    super.initState();
    fetchPreviousCampaigns(currentPage);
  }

  Future<void> fetchPreviousCampaigns(int page) async {
    try {
      final url = Uri.parse(globals.host + '/mediaTeam/previousCampaigns');
      final response = await http.post(
        url,
        headers: {
          'authorization': globals.token,
          'Content-Type': 'application/json'
        },
        body: jsonEncode({'start': page, 'count': 3}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        if (jsonResponse.containsKey('result') &&
            jsonResponse.containsKey('pages')) {
          setState(() {
            previousCampaigns =
                List<Map<String, dynamic>>.from(jsonResponse['result']);
            totalPages = jsonResponse['pages'];
          });
        } else {
          print('Error: Keys "result" or "pages" not found in response');
        }
      } else {
        print('Error fetching previous campaigns: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error fetching previous campaigns: $e');
    }
  }

  void _onPageChanged(int page) {
    if (page <= totalPages && page != currentPage) {
      setState(() {
        currentPage = page;
      });
      fetchPreviousCampaigns(page);
    }
  }

  void _onCampaignTap(int campaignId) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => CampaignDetailsScreen(campaignId: campaignId)),
    );
  }

  void _navigateToAddCampaign() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddCampaignScreen()),
    );

    if (result == true) {
      fetchPreviousCampaigns(currentPage);
    }
  }

  void _onDeleteTap(int campaignId) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => DeleteCampaignScreen(campaignId: campaignId)),
    );

    if (result == true) {
      print('Campaign with ID $campaignId deleted successfully.');
      fetchPreviousCampaigns(currentPage); // Refresh the list after deletion
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Previous Campaigns'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _navigateToAddCampaign,
          ),
        ],
      ),
      body: previousCampaigns.isNotEmpty
          ? Column(
              children: [
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 16.0,
                      mainAxisSpacing: 16.0,
                    ),

                    itemCount: previousCampaigns.length,
                    itemBuilder: (context, index) {
                      final campaign = previousCampaigns[index];
                      return GestureDetector(
                        onTap: () => _onCampaignTap(campaign['id']),
                        child: Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: NetworkImage(globals.host +
                                          '/${campaign['imageurl']}'),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(campaign['title']),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () => _onDeleteTap(campaign['id']),
                                color: Colors.red,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(totalPages, (index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: GestureDetector(
                        onTap: () => _onPageChanged(index + 1),
                        child: CircleAvatar(
                          backgroundColor: index + 1 == currentPage
                              ? AppColors.greenDark
                              : Colors.grey,
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                SizedBox(height: 16),
              ],
            )
          : Center(
             // child: CircularProgressIndicator(),
            ),
    );
  }
}
