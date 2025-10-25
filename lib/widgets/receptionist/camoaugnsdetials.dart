import 'dart:convert';
import 'package:flutter/material.dart';

import '../../globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'donation_screen.dart'; // Import the donation screen

class CampaignDetail {
  final int budget;
  final String targetGroup;
  final String reason;
  final String description;

  CampaignDetail({
    required this.budget,
    required this.targetGroup,
    required this.reason,
    required this.description,
  });

  factory CampaignDetail.fromJson(Map<String, dynamic> json) {
    return CampaignDetail(
      budget: json['budget'] ?? 0,
      targetGroup: json['targetGroup'] ?? '',
      reason: json['reason'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

class CampaignDetailScreen extends StatefulWidget {
  final int campaignId;

  CampaignDetailScreen({required this.campaignId});

  @override
  _CampaignDetailScreenState createState() => _CampaignDetailScreenState();
}

class _CampaignDetailScreenState extends State<CampaignDetailScreen> {
  final String detailsUrl = globals.host + '/receptionist/campaignsDetails';
  CampaignDetail? _campaignDetail;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchCampaignDetails(widget.campaignId);
  }

  Future<void> _fetchCampaignDetails(int id) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(detailsUrl),
        body: jsonEncode({
          'id': id.toString(),
        }),
        headers: {
          'authorization': globals.token,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> responseData = jsonDecode(response.body);
        if (responseData.isNotEmpty) {
          setState(() {
            _campaignDetail = CampaignDetail.fromJson(responseData[0]);
          });
        } else {
          throw Exception('No campaign details found');
        }
      } else {
        throw Exception('Failed to load campaign details');
      }
    } catch (e) {
      print('Error fetching campaign details: $e');
      // Handle error
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToDonate(int campaignId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DonationScreen(campaignId: campaignId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Campaign Details'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _campaignDetail != null
              ? Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Budget: ${_campaignDetail!.budget}'),
                      SizedBox(height: 8),
                      Text('Target Group: ${_campaignDetail!.targetGroup}'),
                      SizedBox(height: 8),
                      Text('Reason: ${_campaignDetail!.reason}'),
                      SizedBox(height: 8),
                      Text('Description: ${_campaignDetail!.description}'),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _navigateToDonate(widget.campaignId),
                        child: Text('Donate'),
                      ),
                    ],
                  ),
                )
              : Center(child: Text('No details available')),
    );
  }
}
