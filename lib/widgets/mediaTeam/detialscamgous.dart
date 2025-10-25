import 'dart:convert';

import 'package:flutter/material.dart';

import '../../globals.dart' as globals;
import 'package:http/http.dart' as http;

class CampaignDetailsScreen extends StatefulWidget {
  final int campaignId;

  CampaignDetailsScreen({required this.campaignId});

  @override
  _CampaignDetailsScreenState createState() => _CampaignDetailsScreenState();
}

class _CampaignDetailsScreenState extends State<CampaignDetailsScreen> {
  List<Map<String, dynamic>> campaignDetails = [];

  @override
  void initState() {
    super.initState();
    fetchCampaignDetails(widget.campaignId);
  }

  Future<void> fetchCampaignDetails(int campaignId) async {
    try {
      final url =
          Uri.parse(globals.host + '/mediaTeam/previousCampaignsDetails');
      final response = await http.post(
        url,
        headers: {
          'authorization': globals.token,
          'Content-Type': 'application/json'
        },
        body: jsonEncode({'id': campaignId}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = jsonDecode(response.body);

        setState(() {
          campaignDetails = List<Map<String, dynamic>>.from(jsonResponse);
        });
      } else {
        print('Error fetching campaign details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching campaign details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Campaign Details'),
      ),
      body: campaignDetails.isNotEmpty
          ? ListView.builder(
              itemCount: campaignDetails.length,
              itemBuilder: (context, index) {
                final detail = campaignDetails[index];
                return ListTile(
                  title: Text(detail['descr']),
                  // Add more fields as needed
                );
              },
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
