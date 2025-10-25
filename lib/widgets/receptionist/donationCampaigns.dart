import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../globals.dart' as globals; // Assuming globals contains the base URL and token

class DonationCampaign {
  final int id;
  final int campaignId;
  final String imageUrl;
  final double cost;
  final DateTime createDate;

  DonationCampaign({
    required this.id,
    required this.campaignId,
    required this.imageUrl,
    required this.cost,
    required this.createDate,
  });

  factory DonationCampaign.fromJson(Map<String, dynamic> json) {
    return DonationCampaign(
      id: json['id'] ?? 0,
      campaignId: json['campaignid'] ?? 0,
      imageUrl: json['imageurl'] ?? '',
      cost: (json['cost'] ?? 0).toDouble(),
      createDate: DateTime.parse(json['createDate'] ?? ''),
    );
  }
}

class DonationCampaignsScreenn extends StatefulWidget {
  int id ;
  int userId ;
  DonationCampaignsScreenn({required int this.id ,required int this.userId});
  @override
  _DonationCampaignsScreennState createState() =>
      _DonationCampaignsScreennState(id : this.id,userId:this.userId );
}

class _DonationCampaignsScreennState extends State<DonationCampaignsScreenn> {
  _DonationCampaignsScreennState({required int id ,required int userId});

  final String baseUrl = globals.host + '/receptionist/donationCampaigns';
  List<DonationCampaign> _donationCampaigns = [];
  bool _isLoading = false;
  TextEditingController _idController = TextEditingController();
  TextEditingController _idUserController = TextEditingController(text: globals.userId);

  Future<void> _fetchDonationCampaigns(int id, int idUser) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'authorization': globals.token,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'id': id,
          'idUser': idUser,
        }),
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = jsonDecode(response.body);
        List<DonationCampaign> donationCampaigns = jsonResponse
            .map((e) => DonationCampaign.fromJson(e))
            .toList();
        setState(() {
          _donationCampaigns = donationCampaigns;
        });
      } else {
        throw Exception('Failed to load donation campaigns');
      }
    } catch (e) {
      print('Error fetching donation campaigns: $e');
      // Handle error
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Donation Campaigns'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
           /* TextField(
              controller: _idController,
              decoration: InputDecoration(
                labelText: 'Enter ID',
              ),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _idUserController,
              decoration: InputDecoration(
                labelText: 'Enter User ID',
              ),
              keyboardType: TextInputType.number,
            ),*/
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                //final id = int.tryParse(_idController.text);
               // final idUser = int.tryParse(_idUserController.text);

                  _fetchDonationCampaigns(widget.id, widget.userId);

                  // Handle invalid input

              },
              child: Text('Fetch Donation Campaigns'),
            ),
            SizedBox(height: 20),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : _donationCampaigns.isEmpty
                ? Center(child: Text('No donation campaigns found'))
                : Expanded(

                    child:ListView.builder(
                     itemCount: _donationCampaigns.length,
                       itemBuilder: (context, index) {

                        return Column(
                          children:[
                              Image.network(
                           globals.host +
                               '/' +
                               _donationCampaigns[index]
                                   .imageUrl,
                           fit: BoxFit.cover,
                         ),

                          Text(
                         'Campaign ID: ${_donationCampaigns[index].campaignId}'),

                         Text(
                         'Cost: \$${_donationCampaigns[index].cost}'),
                         Text(
                         'Date: ${_donationCampaigns[index].createDate.toLocal().toString().split(' ')[0]}'),



                       ],
                         );
                       }


            ),
            ),
        ])
      ),
    );
  }
}
