import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../globals.dart' as globals;
import 'AddCampaign.dart';



class Campaign {
  final int id;
  final String title;

  Campaign({required this.id, required this.title});

  factory Campaign.fromJson(Map<String, dynamic> json) {
    return Campaign(
      id: json['id'],
      title: json['title'],
    );
  }
}

class CampaignListScreen extends StatefulWidget {
  @override
  _CampaignListScreenState createState() => _CampaignListScreenState();
}

class _CampaignListScreenState extends State<CampaignListScreen> {
  List<Campaign> _campaigns = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCampaigns();
  }

  Future<void> fetchCampaigns() async {
    final response = await http.get(
      Uri.parse(globals.host + '/superAdmin/showCampaigns'),
      headers: {
        'authorization': globals.token,
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      setState(() {
        _campaigns = jsonResponse
            .map<Campaign>((campaign) => Campaign.fromJson(campaign))
            .toList();
        _isLoading = false;
      });
    } else {
      throw Exception('Failed to load campaigns');
    }
  }

  Future<void> deleteCampaign(int id) async {
    final response = await http.post(
      Uri.parse(globals.host + '/superAdmin/deleteCampaigns'),
      headers: {
        'authorization': globals.token,
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, int>{'id': id}),
    );

    if (response.statusCode == 200) {
      setState(() {
        _campaigns.removeWhere((campaign) => campaign.id == id);
      });
    } else {
      throw Exception('Failed to delete campaign');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Campaigns'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              bool result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AdddCampaignScreen(),
                ),
              );

              if (result == true) {
                fetchCampaigns(); // Refresh the list after adding a new campaign
              }
            },
          ),
        ],
      ),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : ListView.builder(
          itemCount: _campaigns.length,
          itemBuilder: (context, index) {
            return Card(
              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              elevation: 3,
              child: ListTile(
                title: Text(_campaigns[index].title),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    deleteCampaign(_campaigns[index].id);
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
