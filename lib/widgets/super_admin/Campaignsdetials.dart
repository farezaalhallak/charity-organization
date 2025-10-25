import 'dart:convert';
import 'package:flutter/material.dart';

import '../../globals.dart' as globals;
import 'package:http/http.dart' as http;

class CampaignDetails extends StatefulWidget {
  final int campaignId;

  CampaignDetails({required this.campaignId});

  @override
  _CampaignDetailsState createState() => _CampaignDetailsState();
}

class _CampaignDetailsState extends State<CampaignDetails> {
  Map<String, dynamic>? campaignDetails;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCampaignDetails();
  }

  Future<void> fetchCampaignDetails() async {
    try {
      var url = Uri.parse(globals.host + '/superAdmin/campaignsDetails');
      var body = jsonEncode({"id": widget.campaignId});

      var response = await http.post(
        url,
        headers: {
          'authorization': globals.token,
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        // Assuming the first element in the list is the desired campaign details
        if (data.isNotEmpty && data[0] is Map<String, dynamic>) {
          setState(() {
            campaignDetails = data[0];
            isLoading = false;
          });
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception(
            'Failed to load campaign details. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching campaign details: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Campaign Details'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : campaignDetails == null
              ? Center(child: Text('No details available'))
              : Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Budget: ${campaignDetails!['budget']}'),
                      SizedBox(height: 12),
                      Text('Target Group: ${campaignDetails!['TargetGroup']}'),
                      SizedBox(height: 12),
                      Text('Reason: ${campaignDetails!['reason']}'),
                      SizedBox(height: 12),
                      Text('Description: ${campaignDetails!['descr']}'),
                    ],
                  ),
                ),
    );
  }
}
